// swiftlint:disable file_length
import AppIntegrity
import GAnalytics
import MobilePlatformServices
import Networking
@testable import OneLogin
import SecureStore
import XCTest

extension AppQualifyingService {
    
    static func make(analyticsService: OneLoginAnalyticsService = MockAnalyticsService(),
                     appInformationProvider: AppInformationProvider = MockAppInformationService(),
                     sessionManager: SessionManager = MockSessionManager()) -> AppQualifyingService {
        
        return AppQualifyingService(analyticsService: analyticsService,
                                    updateService: appInformationProvider,
                                    sessionManager: sessionManager)
    }
}

// MARK: - App Info Requests
@MainActor
final class AppQualifyingServiceTests: XCTestCase {
    
    func test_appInfoIsRequested() {
        let expectation = expectation(description: #function)
        let mockAppInformationService = MockAppInformationService()
        let appInformationProvider = MockAppInformationServiceExpectation(mockAppInformationService: mockAppInformationService,
                                                                          expectation: expectation)
        
        let sut: AppQualifyingService = .make(appInformationProvider: appInformationProvider)
        
        sut.initiate()
        
        wait(for: [expectation], timeout: 5)
        XCTAssertTrue(mockAppInformationService.didCallFetchAppInfo)
    }
    
    func test_appUnavailable_setsStateCorrectly() {
        // GIVEN app usage is not allowed
        let appInformationProvider = MockAppInformationService()
        appInformationProvider.allowAppUsage = false
        let sut: AppQualifyingService = .make(appInformationProvider: appInformationProvider)
        
        let (appState, _) = waitForAppInfoStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .unavailable)
    }
    
    func test_outdatedApp_setsStateCorrectly() {
        // GIVEN the app is outdated
        let appInformationProvider = MockAppInformationService()
        appInformationProvider.currentVersion = .init(.min, .min, .min)
        let sut: AppQualifyingService = .make(appInformationProvider: appInformationProvider)
        
        let (appState, _) = waitForAppInfoStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .outdated)
    }
    
    func test_upToDateApp_setsStateCorrectly() {
        let releaseFlags = ["TestFlag": true]
        
        let appInformationProvider = MockAppInformationService()
        appInformationProvider.releaseFlags = releaseFlags
        let sut: AppQualifyingService = .make(appInformationProvider: appInformationProvider)
        
        let (appState, _) = waitForAppInfoStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssertEqual(AppEnvironment.remoteReleaseFlags.flags, releaseFlags)
    }
    
    func test_errorThrown_setsStateCorrectly() {
        // GIVEN `appInfo` cannot be accessed
        let appInformationProvider = MockAppInformationService()
        appInformationProvider.errorFromFetchAppInfo = URLError(.timedOut)
        let sut: AppQualifyingService = .make(appInformationProvider: appInformationProvider)
        
        let (appState, _) = waitForAppInfoStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .error)
    }
    
    func test_appInfoOfflineError_setsStateCorrectly() {
        // GIVEN the app is offline
        let appInformationProvider = MockAppInformationService()
        appInformationProvider.errorFromFetchAppInfo = AppInfoError.notConnectedToInternet
        let sut: AppQualifyingService = .make(appInformationProvider: appInformationProvider)
        
        let (appState, _) = waitForAppInfoStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .offline)
    }
    
    func test_accountIntervention_returns() {
        // GIVEN the a receives an account intervention
        let appInformationProvider = MockAppInformationService()
        appInformationProvider.errorFromFetchAppInfo = ServerError(endpoint: "test", errorCode: 400)
        let sut: AppQualifyingService = .make(appInformationProvider: appInformationProvider)
        
        let (_, sessionState) = waitForAppInfoStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertNil(sessionState)
    }
    
    func test_appInfoInvalidError_setsStateCorrectly() {
        let appInformationProvider = MockAppInformationService()
        appInformationProvider.errorFromFetchAppInfo = AppInfoError.invalidResponse
        let sut: AppQualifyingService = .make(appInformationProvider: appInformationProvider)
        
        let (appState, _) = waitForAppInfoStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .unavailable)
    }
}

// MARK: - User State Evaluation
extension AppQualifyingServiceTests {
    
    func test_oneTimeUser_userConfirmed() {
        let sessionManager = MockSessionManager()
        sessionManager.sessionState = .oneTime
        let sut: AppQualifyingService = .make(sessionManager: sessionManager)
        
        let (appState, sessionState) = waitForSessionStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssertEqual(sessionState, .loggedIn)
    }
    
    func test_noExpiryDate_userUnconfirmed() {
        let sut: AppQualifyingService = .make()
        
        let (appState, sessionState) = waitForSessionStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssertEqual(sessionState, .notLoggedIn)
    }
    
    func test_sessionInvalid_userExpired() {
        let sessionManager = MockSessionManager()
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .expired
        let sut: AppQualifyingService = .make(sessionManager: sessionManager)
        
        let (appState, sessionState) = waitForSessionStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssertEqual(sessionState, .expired)
    }
    
    func test_resumeSession_userConfirmed() {
        let sessionManager = MockSessionManager()
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        let sut: AppQualifyingService = .make(sessionManager: sessionManager)
        
        let (appState, sessionState) = waitForSessionStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssertEqual(sessionState, .loggedIn)
    }
    
    func test_resumeSession_noInternet_error() {
        let expectation = expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        
        let sessionManager = MockSessionManager()
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = RefreshTokenExchangeError.noInternet
        let sut: AppQualifyingService = .make(sessionManager: sessionManager)
        
        let (appState, _) = waitForAppInfoStateChange(expectation: expectation, sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .offline)
    }
    
    func test_resumeSession_appIntegrityFailed() {
        let sessionManager = MockSessionManager()
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = RefreshTokenExchangeError.appIntegrityFailed
        let sut: AppQualifyingService = .make(sessionManager: sessionManager)
        
        let (appState, sessionState) = waitForSessionStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssertEqual(sessionState, .appIntegrityCheckFailed)
    }
    
    func test_resumeSession_accountIntervention() throws {
        let analyticsService = MockAnalyticsService()
        let sessionManager = MockSessionManager()
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = ServerError(endpoint: "test", errorCode: 400)
        let sut: AppQualifyingService = .make(analyticsService: analyticsService, sessionManager: sessionManager)
        
        let (_, sessionState) = waitForAppInfoStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        // THEN the original session state is maintained
        let error = try XCTUnwrap(analyticsService.crashesLogged.first as? ServerError)
        XCTAssert(error.errorCode == 400)
        XCTAssertNil(sessionState)
    }
    
    func test_resumeSession_secureStoreError_cantDecryptData() {
        let sessionManager = MockSessionManager()
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = SecureStoreError(.cantDecryptData)
        let sut: AppQualifyingService = .make(sessionManager: sessionManager)
        
        let (appState, sessionState) = waitForSessionStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssert(sessionState == .expired)
    }
    
    func test_resumeSession_secureStoreError() throws {
        let analyticsService = MockAnalyticsService()
        
        let sessionManager = MockSessionManager()
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = SecureStoreError(.unableToRetrieveFromUserDefaults)
        
        let sut: AppQualifyingService = .make(analyticsService: analyticsService,
                                              sessionManager: sessionManager)
        
        let (appState, sessionState) = waitForSessionStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        let error = try XCTUnwrap(analyticsService.crashesLogged.first as? SecureStoreError)
        XCTAssert(error.kind == .unableToRetrieveFromUserDefaults)
        XCTAssertFalse(sessionManager.didCallClearAllSessionData)
        XCTAssertEqual(sessionState, .localAuthCancelled)
    }
    
    func test_resumeSession_secureStoreError_keepsSessionData() {
        let sessionManager = MockSessionManager()
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = SecureStoreError(.cantDecryptData)
        let sut: AppQualifyingService = .make(sessionManager: sessionManager)
        
        let (appState, sessionState) = waitForAppInfoStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssertNotEqual(sessionState, .failed(MockWalletError.cantDelete))
    }
    
    func test_resumeSession_userRemovedLocalAuth_clearSessionData() {
        let analyticsService = MockAnalyticsService()
        
        let sessionManager = MockSessionManager()
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = PersistentSessionError(.userRemovedLocalAuth)
        
        let sut: AppQualifyingService = .make(analyticsService: analyticsService,
                                              sessionManager: sessionManager)
        
        let (appState, sessionState) = waitForSessionStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssert(analyticsService.crashesLogged.first as? PersistentSessionError == PersistentSessionError(.userRemovedLocalAuth))
        XCTAssert(sessionManager.didCallClearAllSessionData)
        XCTAssertEqual(sessionState, .systemLogOut)
    }
    
    func test_resumeSession_noPersistentSessionError_clearSessionData() {
        let analyticsService = MockAnalyticsService()
        
        let sessionManager = MockSessionManager()
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = PersistentSessionError(.noSessionExists)
        
        let sut: AppQualifyingService = .make(analyticsService: analyticsService,
                                              sessionManager: sessionManager)
        
        let (appState, sessionState) = waitForSessionStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssert(analyticsService.crashesLogged.first as? PersistentSessionError == PersistentSessionError(.noSessionExists))
        XCTAssert(sessionManager.didCallClearAllSessionData)
        XCTAssertEqual(sessionState, .systemLogOut)
    }
    
    func test_resumeSession_idTokenNotStoredError_clearSessionData() {
        let analyticsService = MockAnalyticsService()
        
        let sessionManager = MockSessionManager()
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = PersistentSessionError(.idTokenNotStored)
        
        let sut: AppQualifyingService = .make(analyticsService: analyticsService,
                                              sessionManager: sessionManager)
        
        let (appState, sessionState) = waitForSessionStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssert(analyticsService.crashesLogged.first as? PersistentSessionError == PersistentSessionError(.idTokenNotStored))
        XCTAssert(sessionManager.didCallClearAllSessionData)
        XCTAssertEqual(sessionState, .systemLogOut)
    }
    
    func test_resumeSession_idTokenNotStoredError_clearSessionDataFails() {
        let analyticsService = MockAnalyticsService()
        
        let sessionManager = MockSessionManager()
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = PersistentSessionError(.idTokenNotStored)
        sessionManager.errorFromClearAllSessionData = MockWalletError.cantDelete
        let sut: AppQualifyingService = .make(analyticsService: analyticsService,
                                              sessionManager: sessionManager)
        
        let (appState, sessionState) = waitForSessionStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssert(analyticsService.crashesLogged.first as? PersistentSessionError == PersistentSessionError(.idTokenNotStored))
        XCTAssert(sessionManager.didCallClearAllSessionData)
        XCTAssertEqual(sessionState, .failed(MockWalletError.cantDelete))
    }
    
    /// This test aims to reproduce the case of an app entering into the foreground
    /// which results in a call to ``initiate`` every time.
    ///
    /// Tests that multiple calls to ``initiate`` in quick succession, result in only
    /// a single evaluation of an ``AppSessionState``.
    ///
    /// The test invokes the ``initiate`` function is quick succession to assert that multiple calls
    /// are effectively no-op.
    ///
    /// - SeeAlso: ``SceneDelegate/sceneWillEnterForeground(_:)`
    /// - SeeAlso: ``MockResumeSessionSessionManager``
    func test_multiple_foreground_initiate_calls_only_evaluate_session_state_once() async throws {
        let sessionStates: [SessionState] = [
            .saved
        ]
        let expectedAppSessionStateTransitions = sessionStates.map(\.expectedAppSessionState)
        let sessionStatesReceivedExpectation = expectation(description: "expected session states received")
        sessionStatesReceivedExpectation.assertForOverFulfill = false
        let sessionManager = MockResumeSessionSessionManager(sessionStates: sessionStates)
        let sut: AppQualifyingService = .make(sessionManager: sessionManager)
        var receivedSessionStates = [AppSessionState]()
        let appQualifyingServiceDelegateExpectation = AppQualifyingServiceDelegateExpectation(didChangeSessionStateAsFunction: { sessionState in
            receivedSessionStates.append(sessionState)

            let expectedSessionStateTransitions = Array(expectedAppSessionStateTransitions.prefix(receivedSessionStates.count))
            guard receivedSessionStates == expectedSessionStateTransitions else {
                let issue = XCTIssue(
                    type: .assertionFailure,
                    compactDescription: "Received a session state that was not expected",
                    detailedDescription: "Sequence of received session states \(receivedSessionStates) does not match expected sequence: \(expectedSessionStateTransitions)."
                )
                self.record(issue)
                sessionStatesReceivedExpectation.fulfill()
                return
            }

            if receivedSessionStates.count == expectedAppSessionStateTransitions.count {
                sessionStatesReceivedExpectation.fulfill()
            }
        })

        sut.delegate = appQualifyingServiceDelegateExpectation

        for _ in 0..<10 {
            sut.initiate()
        }
        
        await sut._initiateTask?.value

        await fulfillment(of: [sessionStatesReceivedExpectation], timeout: 5)

        XCTAssertEqual(receivedSessionStates, expectedAppSessionStateTransitions)
    }
    
    /// This test aims to reproduce the case of an app entering into the foreground
    /// which results in a call to ``initiate`` every time.
    ///
    /// It asserts that the session state will be evaluated over time as long as the last evaluation
    /// has been completed.
    ///
    /// The test aims to emulate how a follow up call to ``initiate`` once the last one has finished evaluating
    /// the session state, via ``evaluateUserSession``, will result in another session state evaluation.
    ///
    /// - SeeAlso: ``SceneDelegate/sceneWillEnterForeground(_:)`
    /// - SeeAlso: ``MockResumeSessionSessionManager``
    func test_foreground_initiate_in_sequence_evaluate_every_session_state() async throws {
        let sessionStates: [SessionState] = [
            .nonePresent,
            .saved
        ]
        let expectedAppSessionStateTransitions = sessionStates.map(\.expectedAppSessionState)
        let sessionStatesReceivedExpectation = expectation(description: "expected session states received")
        sessionStatesReceivedExpectation.assertForOverFulfill = false
        let sessionManager = MockResumeSessionSessionManager(sessionStates: sessionStates)
        let sut: AppQualifyingService = .make(sessionManager: sessionManager)
        var receivedSessionStates = [AppSessionState]()
        let appQualifyingServiceDelegateExpectation = AppQualifyingServiceDelegateExpectation(didChangeSessionStateAsFunction: { sessionState in
            receivedSessionStates.append(sessionState)

            let expectedSessionStateTransitions = Array(expectedAppSessionStateTransitions.prefix(receivedSessionStates.count))
            guard receivedSessionStates == expectedSessionStateTransitions else {
                let issue = XCTIssue(
                    type: .assertionFailure,
                    compactDescription: "Received a session state that was not expected",
                    detailedDescription: "Sequence of received session states \(receivedSessionStates) does not match expected sequence: \(expectedSessionStateTransitions)."
                )
                self.record(issue)
                sessionStatesReceivedExpectation.fulfill()
                return
            }

            if receivedSessionStates.count == expectedAppSessionStateTransitions.count {
                sessionStatesReceivedExpectation.fulfill()
            }
        })

        sut.delegate = appQualifyingServiceDelegateExpectation
        
        sut.initiate()
        await sut._initiateTask?.value
        
        sut.initiate()
        await sut._initiateTask?.value

        await fulfillment(of: [sessionStatesReceivedExpectation], timeout: 5)

        XCTAssertEqual(receivedSessionStates, expectedAppSessionStateTransitions)
    }
    
    /// This test aims to reproduce the case of an app entering into the foreground
    /// which results in a call to ``initiate`` every time.
    ///
    /// It asserts that calls to ``evaluateUserSession`` over time, as long as the last
    /// ``AppSessionState`` has been evaluated, will correctly transition to the
    /// next session state.
    ///
    /// The test awaits for the evaluation to complete before attempting to initiate a new one. This way
    /// it aims to emulate how ``initiate`` will create a new task to evaluate the session state
    /// and how the state will transition over time.
    ///
    /// - SeeAlso: ``SceneDelegate/sceneWillEnterForeground(_:)`
    /// - SeeAlso: ``MockResumeSessionSessionManager``
    func test_multiple_foreground_initiate_calls_over_time_transition_sessions_state() async throws {
        let sessionStates: [SessionState] = [
            .nonePresent,
            .enrolling,
            .oneTime,
            .saved,
            .expired,
            .saved,
            .expired,
            .saved,
            .nonePresent,
            .enrolling,
            .saved,
            .expired,
            .saved
        ]
        let expectedAppSessionStateTransitions = sessionStates.map(\.expectedAppSessionState)
        let sessionStatesReceivedExpectation = expectation(description: "expected session states received")
        sessionStatesReceivedExpectation.assertForOverFulfill = false
        let sessionManager = MockResumeSessionSessionManager(sessionStates: sessionStates)
        let sut: AppQualifyingService = .make(sessionManager: sessionManager)
        var receivedSessionStates = [AppSessionState]()
        let appQualifyingServiceDelegateExpectation = AppQualifyingServiceDelegateExpectation(didChangeSessionStateAsFunction: { sessionState in
            receivedSessionStates.append(sessionState)

            let expectedSessionStateTransitions = Array(expectedAppSessionStateTransitions.prefix(receivedSessionStates.count))
            guard receivedSessionStates == expectedSessionStateTransitions else {
                let issue = XCTIssue(
                    type: .assertionFailure,
                    compactDescription: "Received a session state that was not expected",
                    detailedDescription: "Sequence of received session states \(receivedSessionStates) does not match expected sequence: \(expectedSessionStateTransitions)."
                )
                self.record(issue)
                sessionStatesReceivedExpectation.fulfill()
                return
            }

            if receivedSessionStates.count == expectedAppSessionStateTransitions.count {
                sessionStatesReceivedExpectation.fulfill()
            }
        })

        sut.delegate = appQualifyingServiceDelegateExpectation
        
        for _ in 0..<sessionStates.count {
            sut.initiate()
            await sut._initiateTask?.value
        }

        await fulfillment(of: [sessionStatesReceivedExpectation], timeout: 5)

        XCTAssertEqual(receivedSessionStates, expectedAppSessionStateTransitions)
    }
    
    /// This test aims to reproduce the case of an app entering into the foreground
    /// which results in a call to ``initiate`` every time.
    ///
    /// Tests that multiple calls to ``qualifyAppVersion`` in quick succession, result in only
    /// a single evaluation of an ``AppInformationState``.
    ///
    /// The test invokes the ``initiate`` function is quick succession to assert that multiple calls
    /// are effectively no-op.
    ///
    /// - SeeAlso: ``SceneDelegate/sceneWillEnterForeground(_:)``
    /// - SeeAlso: ``AppQualifyingService/appInfoState``
    /// - SeeAlso: ``MockAppInfoAppInformationProvider``
    func test_multiple_foreground_initiate_calls_only_evaluate_information_state_once() async throws {
        let appInformationStates: [AppInformationState] = [
            .qualified
        ]
        let sessionStatesReceivedExpectation = expectation(description: "expected session states received")
        sessionStatesReceivedExpectation.assertForOverFulfill = false
        let sut: AppQualifyingService = .make(appInformationProvider: MockAppInfoAppInformationProvider(appInfoStates: appInformationStates))
        var receivedSessionStates = [AppInformationState]()
        let appQualifyingServiceDelegateExpectation = AppQualifyingServiceDelegateExpectation(didChangeAppInfoStateAsFunction: { sessionState in
            receivedSessionStates.append(sessionState)

            let expectedSessionStateTransitions = Array(appInformationStates.prefix(receivedSessionStates.count))
            guard receivedSessionStates == expectedSessionStateTransitions else {
                let issue = XCTIssue(
                    type: .assertionFailure,
                    compactDescription: "Received a app information state that was not expected",
                    detailedDescription: "Sequence of app information states \(receivedSessionStates) does not match expected sequence: \(expectedSessionStateTransitions)."
                )
                self.record(issue)
                sessionStatesReceivedExpectation.fulfill()
                return
            }

            if receivedSessionStates.count == appInformationStates.count {
                sessionStatesReceivedExpectation.fulfill()
            }
        })

        sut.delegate = appQualifyingServiceDelegateExpectation

        for _ in 0..<appInformationStates.count {
            sut.initiate()
        }

        await sut._initiateTask?.value

        await fulfillment(of: [sessionStatesReceivedExpectation], timeout: 5)

        XCTAssertEqual(receivedSessionStates, appInformationStates)
    }
    
    /// This test aims to reproduce the case of an app entering into the foreground
    /// which results in a call to ``initiate`` every time.
    ///
    /// It asserts that the information state will be evaluated over time as long as the last evaluation
    /// has been completed.
    ///
    /// The test aims to emulate how a follow up call to ``initiate`` once the last one has finished evaluating
    /// the information state, via ``qualifyAppVersion``, will result in another session state evaluation.
    ///
    /// - SeeAlso: ``SceneDelegate/sceneWillEnterForeground(_:)``
    /// - SeeAlso: ``AppQualifyingService/appInfoState``
    /// - SeeAlso: ``MockAppInfoAppInformationProvider``
    func test_foreground_initiate_in_sequence_evaluate_every_information_state() async throws {
        let appInformationStates: [AppInformationState] = [
            .qualified,
            .unavailable
        ]
        let sessionStatesReceivedExpectation = expectation(description: "expected session states received")
        sessionStatesReceivedExpectation.assertForOverFulfill = false
        let sut: AppQualifyingService = .make(appInformationProvider: MockAppInfoAppInformationProvider(appInfoStates: appInformationStates))
        var receivedSessionStates = [AppInformationState]()
        let appQualifyingServiceDelegateExpectation = AppQualifyingServiceDelegateExpectation(didChangeAppInfoStateAsFunction: { sessionState in
            receivedSessionStates.append(sessionState)

            let expectedSessionStateTransitions = Array(appInformationStates.prefix(receivedSessionStates.count))
            guard receivedSessionStates == expectedSessionStateTransitions else {
                let issue = XCTIssue(
                    type: .assertionFailure,
                    compactDescription: "Received a app information state that was not expected",
                    detailedDescription: "Sequence of app information states \(receivedSessionStates) does not match expected sequence: \(expectedSessionStateTransitions)."
                )
                self.record(issue)
                sessionStatesReceivedExpectation.fulfill()
                return
            }

            if receivedSessionStates.count == appInformationStates.count {
                sessionStatesReceivedExpectation.fulfill()
            }
        })

        sut.delegate = appQualifyingServiceDelegateExpectation

        sut.initiate()
        await sut._initiateTask?.value
        
        sut.initiate()
        await sut._initiateTask?.value

        await fulfillment(of: [sessionStatesReceivedExpectation], timeout: 5)

        XCTAssertEqual(receivedSessionStates, appInformationStates)
    }

    /// This test aims to reproduce the case of an app entering into the foreground
    /// which results in a call to ``initiate`` every time.
    ///
    /// It asserts that calls to ``qualifyAppVersion`` over time, as long as the last
    /// ``AppInformationState`` has been evaluated, will correctly transition to the
    /// next information state.
    ///
    /// The test awaits for the evaluation to complete before attempting to initiate a new one. This way
    /// it aims to emulate how ``initiate`` will create a new task to evaluate the information state
    /// and how the state will transition over time.
    ///
    /// - SeeAlso: ``SceneDelegate/sceneWillEnterForeground(_:)``
    /// - SeeAlso: ``AppQualifyingService/appInfoState``
    /// - SeeAlso: ``MockAppInfoAppInformationProvider``
    func test_multiple_foreground_initiate_calls_over_time_transition_information_state() async throws {
        let appInformationStates: [AppInformationState] = [
            .qualified,
            .unavailable,
            .offline,
            .qualified,
            .outdated,
            .error
        ]
        let sessionStatesReceivedExpectation = expectation(description: "expected session states received")
        sessionStatesReceivedExpectation.assertForOverFulfill = false
        let sut: AppQualifyingService = .make(appInformationProvider: MockAppInfoAppInformationProvider(appInfoStates: appInformationStates))
        var receivedSessionStates = [AppInformationState]()
        let appQualifyingServiceDelegateExpectation = AppQualifyingServiceDelegateExpectation(didChangeAppInfoStateAsFunction: { sessionState in
            receivedSessionStates.append(sessionState)

            let expectedSessionStateTransitions = Array(appInformationStates.prefix(receivedSessionStates.count))
            guard receivedSessionStates == expectedSessionStateTransitions else {
                let issue = XCTIssue(
                    type: .assertionFailure,
                    compactDescription: "Received a app information state that was not expected",
                    detailedDescription: "Sequence of app information states \(receivedSessionStates) does not match expected sequence: \(expectedSessionStateTransitions)."
                )
                self.record(issue)
                sessionStatesReceivedExpectation.fulfill()
                return
            }

            if receivedSessionStates.count == appInformationStates.count {
                sessionStatesReceivedExpectation.fulfill()
            }
        })

        sut.delegate = appQualifyingServiceDelegateExpectation

        for _ in 0..<appInformationStates.count {
            sut.initiate()
            await sut._initiateTask?.value
        }

        await fulfillment(of: [sessionStatesReceivedExpectation], timeout: 5)

        XCTAssertEqual(receivedSessionStates, appInformationStates)
    }

    /// This test aims to reproduce the case of a number of notification posting an update on ``RemoteServiceState``.
    ///
    /// Test that multiple calls to ````AppQualifyingService/serviceState`` do not
    /// result in an invalid ``RemoteServiceState`` published.
    ///
    /// Since the ``AppQualifyingService`` **schedules a Task** to perform a callback to the delegate, it's possible that
    /// by the time the task runs and reads the value, the value has since change from another call to ``serviceState``
    ///
    /// Potentially resulting to either an unexpected remote service information state or an invalid transition between states.
    ///
    /// This test aims to catch such a case of an invalid transition between states by posting a number of notifications
    /// and expects them to arrive in the same order, as posted.
    ///
    /// The test posts notifications in  quick succession so as to generate concurrent pressure
    /// by **scheduling of tasks** since ``serviceState`` merely creates a task and there is no way to control/manage
    /// Task execution.
    ///
    /// In other words, this test aims to emulate what would happen should a number of Task(s) have been scheduled
    /// for execution over a short period of time. Creating lots of Tasks in a short period of time aims to *force* the
    /// system to execute themconcurrently. As of today, 2 number of tasks appear to apply enough concurrent pressure.
    /// *This may change in the future*
    ///
    /// - SeeAlso: ``AppQualifyingService/subscribe``
    func test_multiple_serviceState_notifications_do_not_lead_to_invalid_service_state_transition() async throws {
        let serviceStates: [RemoteServiceState] = [
            .accountIntervention,
            .reauthenticationRequired
        ]
        let sessionStatesReceivedExpectation = expectation(description: "expected session states received")
        sessionStatesReceivedExpectation.assertForOverFulfill = false
        let sut: AppQualifyingService = .make()
        var receivedSessionStates = [RemoteServiceState]()
        let appQualifyingServiceDelegateExpectation = AppQualifyingServiceDelegateExpectation(didChangeServiceStateAsFunction: { sessionState in
            receivedSessionStates.append(sessionState)

            let expectedServiceStates = Array(serviceStates.prefix(receivedSessionStates.count))
            guard receivedSessionStates == expectedServiceStates else {
                let issue = XCTIssue(
                    type: .assertionFailure,
                    compactDescription: "Received a remove service state that was not expected",
                    detailedDescription: "Sequence of received remote service states \(receivedSessionStates) does not match expected sequence: \(expectedServiceStates)."
                )
                self.record(issue)
                sessionStatesReceivedExpectation.fulfill()
                return
            }

            if receivedSessionStates.count == expectedServiceStates.count {
                sessionStatesReceivedExpectation.fulfill()
            }
        })

        sut.delegate = appQualifyingServiceDelegateExpectation

        let notifications: [Notification.Name] = serviceStates.compactMap { remoteServiceState in
            switch remoteServiceState {
            case .accountIntervention:
                return .accountIntervention
            case .reauthenticationRequired:
                return .reauthenticationRequired
            default:
                return nil
            }
        }
        for notification in notifications {
            NotificationCenter.default.post(name: notification)
        }

        await fulfillment(of: [sessionStatesReceivedExpectation], timeout: 5)

        XCTAssertEqual(receivedSessionStates, serviceStates)
    }
}

// MARK: - Subscription Tests
extension AppQualifyingServiceTests {
    
    func test_enrolmentComplete_changesSessionState() {
        let appInformationProvider = MockAppInformationService()
        appInformationProvider.errorFromFetchAppInfo = AppInfoError.invalidResponse
        let sut: AppQualifyingService = .make(appInformationProvider: appInformationProvider)
        
        let (_, sessionState) = waitForSessionStateChange(sut: sut, when: { _ in
            NotificationCenter.default.post(name: .enrolmentComplete)
        })
        
        XCTAssertEqual(sessionState, .loggedIn)
    }
    
    func test_sessionExpiry_changesSessionState() {
        let appInformationProvider = MockAppInformationService()
        appInformationProvider.errorFromFetchAppInfo = AppInfoError.invalidResponse
        let sut: AppQualifyingService = .make(appInformationProvider: appInformationProvider)
        
        let (_, sessionState) = waitForSessionStateChange(sut: sut, when: { _ in
            NotificationCenter.default.post(name: .sessionExpired)
        })
        
        XCTAssertEqual(sessionState, .expired)
    }
    
    func test_logOut_changesSessionState() {
        let appInformationProvider = MockAppInformationService()
        appInformationProvider.errorFromFetchAppInfo = AppInfoError.invalidResponse
        let sut: AppQualifyingService = .make(appInformationProvider: appInformationProvider)
        
        let (_, sessionState) = waitForSessionStateChange(sut: sut, when: { _ in
            NotificationCenter.default.post(name: .systemLogUserOut)
        })
        
        XCTAssertEqual(sessionState, .systemLogOut)
    }
    
    func test_initiate_resumeSession_with_firebaseAppCheck() throws {
        let analyticsService = MockAnalyticsService()
        let sessionManager = MockSessionManager()
        sessionManager.sessionState = .oneTime
        
        let sut = AppQualifyingService(analyticsService: analyticsService,
                                       updateService: MockAppInformationService(),
                                       sessionManager: sessionManager)
        
        let (appState, sessionState) = waitForSessionStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssertEqual(sessionState, .loggedIn)
    }
    
    func waitForSessionStateChange(expectation e: XCTestExpectation? = nil,
                                   sut: AppQualifyingService,
                                   when: (AppQualifyingService) -> Void)
    -> (appState: AppInformationState?, sessionState: AppSessionState?) {
        let expectation = e ?? expectation(description: #function)
        var _appState: AppInformationState?
        var _sessionState: AppSessionState?

        let appQualifyingServiceDelegateExpectation = AppQualifyingServiceDelegateExpectation(didChangeAppInfoStateAsFunction: { appState in
            _appState = appState
        }, didChangeSessionStateAsFunction: { sessionState in
            _sessionState = sessionState
            expectation.fulfill()
        })
        
        sut.delegate = appQualifyingServiceDelegateExpectation
        when(sut)
        
        wait(for: [expectation], timeout: 5)
        
        return (appState: _appState, sessionState: _sessionState)
    }
    
    func waitForAppInfoStateChange(expectation e: XCTestExpectation? = nil,
                                   sut: AppQualifyingService,
                                   when: (AppQualifyingService) -> Void)
    -> (appState: AppInformationState?, sessionState: AppSessionState?) {
        let expectation = e ?? expectation(description: #function)
        var _appState: AppInformationState?
        var _sessionState: AppSessionState?

        let appQualifyingServiceDelegateExpectation = AppQualifyingServiceDelegateExpectation(didChangeAppInfoStateAsFunction: { appState in
            _appState = appState
            expectation.fulfill()
        }, didChangeSessionStateAsFunction: { sessionState in
            _sessionState = sessionState
        })
        
        sut.delegate = appQualifyingServiceDelegateExpectation
        when(sut)
        
        wait(for: [expectation], timeout: 5)
        
        return (appState: _appState, sessionState: _sessionState)
    }
}

@MainActor
class AppQualifyingServiceDelegateExpectation: AppQualifyingServiceDelegate {
    
    typealias DidChangeAppInfoState = (AppInformationState) -> Void
    typealias DidChangeSessionState = (AppSessionState) -> Void
    typealias DidChangeServiceState = (RemoteServiceState) -> Void
    
    let didChangeAppInfoStateAsFunction: DidChangeAppInfoState
    let didChangeSessionStateAsFunction: DidChangeSessionState
    let didChangeServiceStateAsFunction: DidChangeServiceState
    
    init(didChangeAppInfoStateAsFunction: @escaping DidChangeAppInfoState = { _ in },
         didChangeSessionStateAsFunction: @escaping DidChangeSessionState = { _ in },
         didChangeServiceStateAsFunction: @escaping DidChangeServiceState = { _ in }) {
        self.didChangeAppInfoStateAsFunction = didChangeAppInfoStateAsFunction
        self.didChangeSessionStateAsFunction = didChangeSessionStateAsFunction
        self.didChangeServiceStateAsFunction = didChangeServiceStateAsFunction
    }
    
    func didChangeAppInfoState(state appInfoState: AppInformationState) {
        self.didChangeAppInfoStateAsFunction(appInfoState)
    }
    
    func didChangeSessionState(state sessionState: AppSessionState) {
        self.didChangeSessionStateAsFunction(sessionState)
    }
    
    func didChangeServiceState(state: RemoteServiceState) {
        self.didChangeServiceStateAsFunction(state)
    }
}

private extension SessionState {
    var expectedAppSessionState: AppSessionState {
        switch self {
        case .expired:
            return .expired
        case .enrolling, .nonePresent:
            return .notLoggedIn
        case .oneTime, .saved:
            return .loggedIn
        }
    }
}
