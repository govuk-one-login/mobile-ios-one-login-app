import Coordination
import LocalAuthenticationWrapper
import Networking
@testable import OneLogin
import XCTest

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
final class OneLoginEnrolmentManagerTests: XCTestCase {
    enum MockError: Error {
        case generic
    }

    func test_saveSession_succeeds() async {
        let exp = XCTNSNotificationExpectation(
            name: .enrolmentComplete,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        let mockLocalAuthContext = MockLocalAuthManager()
        let sut: OneLoginEnrolmentManager = .make(mockLocalAuthContext: mockLocalAuthContext)

        // GIVEN the user has given FaceID permission
        mockLocalAuthContext.userDidConsentToFaceID = true
        // WHEN saveSession is called
        sut.saveSession()
        // THEN enrolment complete notification is sent
        await fulfillment(of: [exp], timeout: 5)
    }

    func test_saveSession_fails() {
        let expectation = expectation(description: #function)
        // GIVEN the user has given FaceID permission
        let mockLocalAuthContext = MockLocalAuthManager()
        mockLocalAuthContext.userDidConsentToFaceID = true
        // GIVEN saveSession returns an uncaught error
        let mockSessionManager = MockSessionManager()
        let mockSessionManagerExpectation = MockSessionManagerExpectation(sessionManager: mockSessionManager, didSaveAuthSessionAsFunction: {
            expectation.fulfill()
        })
        
        mockSessionManager.errorFromSaveSession = MockError.generic
        let mockAnalyticsService = MockAnalyticsService()
        let sut: OneLoginEnrolmentManager = .make(mockLocalAuthContext: mockLocalAuthContext,
                                                  mockSessionManager: mockSessionManagerExpectation,
                                                  mockAnalyticsService: mockAnalyticsService)
        
        // WHEN saveSession is called
        sut.saveSession()
        
        self.wait(for: [expectation], timeout: 5)
        XCTAssertTrue(mockSessionManager.didCallSaveSession)
        // THEN an error is recorded in Crashlytics
        XCTAssertEqual(mockAnalyticsService.crashesLogged, [MockError.generic as NSError])
    }

    func test_saveSession_promptForPermission_false() {
        let expectation = expectation(description: #function)
        // GIVEN the user has already given FaceID permission
        let mockLocalAuthManager = MockLocalAuthManager()
        let mockLocalAuthManagerExpectation = MockLocalAuthManagerExpectation(mockLocalAuthManager: mockLocalAuthManager,
                                                                   expectation: expectation)
        mockLocalAuthManager.userDidConsentToFaceID = false
        let mockAnalyticsService = MockAnalyticsService()
        let sut: OneLoginEnrolmentManager = .make(mockLocalAuthContext: mockLocalAuthManagerExpectation,
                                                  mockAnalyticsService: mockAnalyticsService)
        // WHEN saveSession is called
        sut.saveSession()
        wait(for: [expectation], timeout: 5)
        XCTAssertTrue(mockLocalAuthManager.didCallEnrolFaceIDIfAvailable)
        // THEN no error is recorded in Crashlytics
        XCTAssertEqual(mockAnalyticsService.crashesLogged, [])
    }

    func test_saveSession_promptForPermission_cancelled() {
        let expectation = expectation(description: #function)
        // GIVEN promptForPermission throws a cancelled error
        let mockLocalAuthManager = MockLocalAuthManager()
        let mockLocalAuthManagerExpectation = MockLocalAuthManagerExpectation(mockLocalAuthManager: mockLocalAuthManager,
                                                                   expectation: expectation)
        mockLocalAuthManager.errorFromEnrolLocalAuth = LocalAuthenticationWrapperError.cancelled
        let mockAnalyticsService = MockAnalyticsService()
        let sut: OneLoginEnrolmentManager = .make(mockLocalAuthContext: mockLocalAuthManagerExpectation,
                                                  mockAnalyticsService: mockAnalyticsService)
        // WHEN saveSession is called
        sut.saveSession()
        wait(for: [expectation], timeout: 5)
        XCTAssertTrue(mockLocalAuthManager.didCallEnrolFaceIDIfAvailable)
        // THEN no error is recorded in Crashlytics
        XCTAssertEqual(mockAnalyticsService.crashesLogged, [])
    }

    func test_saveSession_promptForPermission_fails() {
        let expectation = expectation(description: #function)
        // GIVEN promptForPermission throws an uncaught error
        let mockLocalAuthContext = MockLocalAuthManager()
        mockLocalAuthContext.errorFromEnrolLocalAuth = MockError.generic
        let mockAnalyticsService = MockAnalyticsServiceExpectation(expectation: expectation)
        let sut: OneLoginEnrolmentManager = .make(mockLocalAuthContext: mockLocalAuthContext,
                                                  mockAnalyticsService: mockAnalyticsService)
        // WHEN saveSession is called
        sut.saveSession()
        wait(for: [expectation], timeout: 5)
        XCTAssertTrue(mockLocalAuthContext.didCallEnrolFaceIDIfAvailable)
        // THEN an error is recorded in Crashlytics
        XCTAssertEqual(mockAnalyticsService.crashesLogged, [MockError.generic as NSError])
    }

    func test_saveSession_isWalletEnrolmentTrue_finishOnCoordinator_not_called() {
        //  GIVEN OneLoginEnrolmentManager with a coordinator
        //  WHEN performing save session
        //  AND `isWalletEnrolment` is true
        //  ASSERT that `finish` is NOT called on the coordinator

        let expectation = expectation(description: #function)
        expectation.isInverted = true
        let mockChildCoordinatorExpectation = MockChildCoordinatorExpectation(finishAsFunction: {
            expectation.fulfill()
        })

        let sut: OneLoginEnrolmentManager = .make(coordinator: mockChildCoordinatorExpectation)
        // WHEN saveSession is called
        sut.saveSession(isWalletEnrolment: true)
        let result = XCTWaiter().wait(for: [expectation], timeout: 1)
        XCTAssertEqual(result, .completed)
    }

    func test_saveSession_isWalletEnrolmentFalse_finishOnCoordinator_called() {
        //  GIVEN OneLoginEnrolmentManager with a coordinator
        //  WHEN performing save session
        //  AND `isWalletEnrolment` is false
        //  ASSERT that `finish` is called on the coordinator

        let expectation = expectation(description: #function)
        let mockChildCoordinatorExpectation = MockChildCoordinatorExpectation(finishAsFunction: {
            expectation.fulfill()
        })

        let sut: OneLoginEnrolmentManager = .make(coordinator: mockChildCoordinatorExpectation)
        // WHEN saveSession is called
        sut.saveSession(isWalletEnrolment: false)
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(result, .completed)
    }

    func test_saveSession_default_finishOnCoordinator_called() {
        //  GIVEN OneLoginEnrolmentManager with a coordinator
        //  WHEN performing save session (where by default `isWalletEnrolment` is false)
        //  ASSERT that `finish` is called on the coordinator

        let expectation = expectation(description: #function)
        let mockChildCoordinatorExpectation = MockChildCoordinatorExpectation(finishAsFunction: {
            expectation.fulfill()
        })

        let sut: OneLoginEnrolmentManager = .make(coordinator: mockChildCoordinatorExpectation)
        // WHEN saveSession is called
        sut.saveSession()
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(result, .completed)
    }

    func test_saveSession_isWalletEnrolmentTrue_walletCoordinator_notRemoved_asChild() {
        //  GIVEN a `TabManagerCoordinator`
        //  AND a `WalletCoordinator`
        //  WITH a a parent/child relationship
        //  WHEN performing save session
        //  AND `isWalletEnrolment` is true
        //  ASSERT that the `WalletCoordinator` is not removed as a child
        let mockAnalyticsService = MockAnalyticsService()
        let mockSessionManager = MockSessionManager()
        let expectation = expectation(description: #function)
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
        // WHEN saveSession is called
        sut.saveSession(isWalletEnrolment: true) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        XCTAssert(tabManagerCoordinator.childCoordinators.count == 1)
    }
}
