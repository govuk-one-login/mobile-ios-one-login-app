import Coordination
import Foundation
import LocalAuthenticationWrapper
import Networking
@testable import OneLogin
import Testing
import UIKit

extension OneLoginEnrolmentManager {
    static func make(
        mockLocalAuthContext: LocalAuthManaging = MockLocalAuthManager(),
        mockSessionManager: SessionManager = MockSessionManager(),
        mockAnalyticsService: OneLoginAnalyticsService = MockAnalyticsService(),
        coordinator: ChildCoordinator? = nil
    ) -> OneLoginEnrolmentManager {
        let coordinator =
            coordinator
            ?? EnrolmentCoordinator(
                root: UINavigationController(),
                analyticsService: mockAnalyticsService,
                sessionManager: mockSessionManager
            )
        return OneLoginEnrolmentManager(
            localAuthContext: mockLocalAuthContext,
            sessionManager: mockSessionManager,
            analyticsService: mockAnalyticsService,
            coordinator: coordinator
        )
    }
}

@MainActor
struct OneLoginEnrolmentManagerTests {
    enum MockError: Error {
        case generic
    }

    @Test
    func test_saveSession_succeeds() async {
        let mockLocalAuthContext = MockLocalAuthManager()
        let sut: OneLoginEnrolmentManager = .make(mockLocalAuthContext: mockLocalAuthContext)
        
        // GIVEN the user has given FaceID permission
        mockLocalAuthContext.userDidConsentToFaceID = true
        
        await confirmation("enrolment notification posted") { confirmation in
            let observer = NotificationCenter.default.addObserver(forName: .enrolmentComplete,
                                                                  object: nil,
                                                                  queue: nil) { _ in
                // THEN enrolment complete notification is sent
                confirmation()
            }
            
            defer {
                NotificationCenter.default.removeObserver(observer)
            }
            
            // WHEN saveSession is called
            await sut.saveSession()
        }
    }

    @Test
    func test_saveSession_fails() async {
        // GIVEN the user has given FaceID permission
        let mockLocalAuthManager = MockLocalAuthManager()
        mockLocalAuthManager.userDidConsentToFaceID = true
        // GIVEN saveSession returns an uncaught error
        let mockSessionManager = MockSessionManager()
        
        mockSessionManager.errorFromSaveSession = MockError.generic
        let mockAnalyticsService = MockAnalyticsService()
        
        await confirmation("save session fails") { confirmation in
            let mockSessionManagerExpectation = MockSessionManagerExpectation(sessionManager: mockSessionManager, didSaveAuthSessionAsFunction: {
                confirmation()
            })
            let sut: OneLoginEnrolmentManager = .make(mockLocalAuthContext: mockLocalAuthManager,
                                                      mockSessionManager: mockSessionManagerExpectation,
                                                      mockAnalyticsService: mockAnalyticsService)
            // WHEN saveSession is called
            await sut.saveSession()
        }
              
        #expect(mockSessionManager.didCallSaveSession)
        // THEN an error is recorded in Crashlytics
        #expect(mockAnalyticsService.crashesLogged == [MockError.generic as NSError])
    }

    @Test
    func test_saveSession_promptForPermission_false() async {
        // GIVEN the user has already given FaceID permission
        let mockLocalAuthManager = MockLocalAuthManager()
        let mockAnalyticsService = MockAnalyticsService()
        mockLocalAuthManager.userDidConsentToFaceID = false
        
        await confirmation("promptForPermission called") { confirmation in
            let mockLocalAuthManagerExpectation = MockLocalAuthManagerExpectation(mockLocalAuthManager: mockLocalAuthManager) {
                confirmation()
            }
            let sut: OneLoginEnrolmentManager = .make(mockLocalAuthContext: mockLocalAuthManagerExpectation,
                                                      mockAnalyticsService: mockAnalyticsService)
            // WHEN saveSession is called
            await sut.saveSession()
        }

        #expect(mockLocalAuthManager.didCallEnrolFaceIDIfAvailable)
        // THEN no error is recorded in Crashlytics
        #expect(mockAnalyticsService.crashesLogged == [])
    }

    @Test
    func test_saveSession_promptForPermission_cancelled() async {
        // GIVEN promptForPermission throws a cancelled error
        let mockLocalAuthManager = MockLocalAuthManager()
        mockLocalAuthManager.errorFromEnrolLocalAuth = LocalAuthenticationWrapperError.cancelled
        let mockAnalyticsService = MockAnalyticsService()
        
        await confirmation("promptForPermission is cancelled") { confirmation in
            let mockLocalAuthManagerExpectation = MockLocalAuthManagerExpectation(mockLocalAuthManager: mockLocalAuthManager) {
                confirmation()
            }
            let sut: OneLoginEnrolmentManager = .make(mockLocalAuthContext: mockLocalAuthManagerExpectation,
                                                      mockAnalyticsService: mockAnalyticsService)
            // WHEN saveSession is called
            await sut.saveSession()
        }
        
        #expect(mockLocalAuthManager.didCallEnrolFaceIDIfAvailable)
        // THEN no error is recorded in Crashlytics
        #expect(mockAnalyticsService.crashesLogged == [])
    }

    @Test
    func test_saveSession_promptForPermission_fails() async {
        // GIVEN promptForPermission throws an uncaught error
        let mockLocalAuthContext = MockLocalAuthManager()
        mockLocalAuthContext.errorFromEnrolLocalAuth = MockError.generic
        
        let mockAnalyticsService = MockAnalyticsServiceExpectation(onLogCrash: {})
        
        await confirmation("promptForPermission fails") { confirmation in
            mockAnalyticsService.onLogCrash = {
                confirmation()
            }
            let sut: OneLoginEnrolmentManager = .make(mockLocalAuthContext: mockLocalAuthContext,
                                                      mockAnalyticsService: mockAnalyticsService)
            // WHEN saveSession is called
            await sut.saveSession()
        }
        #expect(mockLocalAuthContext.didCallEnrolFaceIDIfAvailable)
        // THEN an error is recorded in Crashlytics
        #expect(mockAnalyticsService.crashesLogged == [MockError.generic as NSError])
    }

    @Test
    func test_saveSession_isWalletEnrolmentTrue_finishOnCoordinator_not_called() async {
        //  GIVEN OneLoginEnrolmentManager with a coordinator
        //  WHEN performing save session
        //  AND `isWalletEnrolment` is true
        //  ASSERT that `finish` is NOT called on the coordinator

        await confirmation("finishOnCoordinator not called", expectedCount: 0) { confirmation in
            let mockChildCoordinatorExpectation = MockChildCoordinatorExpectation(finishAsFunction: {
                confirmation()
            })
            let sut: OneLoginEnrolmentManager = .make(coordinator: mockChildCoordinatorExpectation)
            
            // WHEN saveSession is called
            await sut.saveSession(isWalletEnrolment: true)
        }
    }

    @Test
    func test_saveSession_isWalletEnrolmentFalse_finishOnCoordinator_called() async {
        //  GIVEN OneLoginEnrolmentManager with a coordinator
        //  WHEN performing save session
        //  AND `isWalletEnrolment` is false
        //  ASSERT that `finish` is called on the coordinator
        
        await confirmation("finishOnCoordinator called") { confirmation in
            let mockChildCoordinatorExpectation = MockChildCoordinatorExpectation(finishAsFunction: {
                confirmation()
            })
            let sut: OneLoginEnrolmentManager = .make(coordinator: mockChildCoordinatorExpectation)
            
            // WHEN saveSession is called
            await sut.saveSession(isWalletEnrolment: false)
        }
    }

    @Test
    func test_saveSession_default_finishOnCoordinator_called() async {
        //  GIVEN OneLoginEnrolmentManager with a coordinator
        //  WHEN performing save session (where by default `isWalletEnrolment` is false)
        //  ASSERT that `finish` is called on the coordinator

        await confirmation("finishOnCoordinator called") { confirmation in
            let mockChildCoordinatorExpectation = MockChildCoordinatorExpectation(finishAsFunction: {
                confirmation()
            })
            let sut: OneLoginEnrolmentManager = .make(coordinator: mockChildCoordinatorExpectation)
            
            // WHEN saveSession is called
            await sut.saveSession()
        }
    }

    @Test
    func test_saveSession_isWalletEnrolmentTrue_walletCoordinator_notRemoved_asChild() async {
        //  GIVEN a `TabManagerCoordinator`
        //  AND a `WalletCoordinator`
        //  WITH a a parent/child relationship
        //  WHEN performing save session
        //  AND `isWalletEnrolment` is true
        //  ASSERT that the `WalletCoordinator` is not removed as a child
        let mockAnalyticsService = MockAnalyticsService()
        let mockSessionManager = MockSessionManager()
        let tabManagerCoordinator = TabManagerCoordinator(
            root: UITabBarController(),
            analyticsService: mockAnalyticsService,
            networkingService: NetworkClient(),
            sessionManager: mockSessionManager
        )

        let walletCoordinator = WalletCoordinator(
            analyticsService: mockAnalyticsService,
            networkingService: NetworkClient(),
            sessionManager: mockSessionManager
        )

        tabManagerCoordinator.childCoordinators.append(walletCoordinator)
        walletCoordinator.parentCoordinator = tabManagerCoordinator

        let sut: OneLoginEnrolmentManager = .make(coordinator: walletCoordinator)

        await confirmation("wallet coordinator not removed") { confirmation in
            // WHEN saveSession is called
            await sut.saveSession(isWalletEnrolment: true) {
                confirmation()
            }
        }
        
        #expect(tabManagerCoordinator.childCoordinators.count == 1)
    }
}
