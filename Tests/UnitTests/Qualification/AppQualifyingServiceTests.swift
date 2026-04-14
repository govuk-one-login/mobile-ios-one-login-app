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
                     sessionManager: SessionManager = MockSessionManager(),
                     appIntegrityProvider: AppIntegrityProvider = AppIntegrityProviderStub()) -> AppQualifyingService {
        
        return AppQualifyingService(analyticsService: analyticsService,
                                    updateService: appInformationProvider,
                                    sessionManager: sessionManager,
                                    appIntegrityProvider: appIntegrityProvider)
    }
}

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

final class AppQualifyingServiceTests: XCTestCase {
}

// MARK: - App Info Requests
extension AppQualifyingServiceTests {
    
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
    
    @MainActor
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

    @MainActor
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

    @MainActor
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

    @MainActor
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
    
    @MainActor
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
    
    @MainActor
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
    
    @MainActor
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
    
    @MainActor
    func waitForSessionStateChange(expectation e: XCTestExpectation? = nil,
                                   sut: AppQualifyingService,
                                   when: (AppQualifyingService) -> Void) -> (appState: AppInformationState?, sessionState: AppSessionState?) {
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
    
    @MainActor
    func waitForAppInfoStateChange(expectation e: XCTestExpectation? = nil,
                                   sut: AppQualifyingService,
                                   when: (AppQualifyingService) -> Void) -> (appState: AppInformationState?, sessionState: AppSessionState?) {
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

    
    @MainActor
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
    
    @MainActor
    func test_noExpiryDate_userUnconfirmed() {
        let sut: AppQualifyingService = .make()

        let (appState, sessionState) = waitForSessionStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssertEqual(sessionState, .notLoggedIn)
    }
    
    @MainActor
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
    
    @MainActor
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
    
    @MainActor
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
    
    @MainActor
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
    
    @MainActor
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
    
    @MainActor
    func test_resumeSession_secureStoreError_cantDecryptData() {
        let sessionManager = MockSessionManager()
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = SecureStoreErrorV2(.cantDecryptData)
        let sut: AppQualifyingService = .make(sessionManager: sessionManager)

        let (appState, sessionState) = waitForSessionStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssert(sessionState == .expired)
    }
    
    @MainActor
    func test_resumeSession_secureStoreError() throws {
        let analyticsService = MockAnalyticsService()
        
        let sessionManager = MockSessionManager()
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = SecureStoreErrorV2(.unableToRetrieveFromUserDefaults)
        
        let sut: AppQualifyingService = .make(analyticsService: analyticsService,
                                              sessionManager: sessionManager)

        let (appState, sessionState) = waitForSessionStateChange(sut: sut, when: { sut in
            sut.initiate()
        })

        XCTAssertEqual(appState, .qualified)
        let error = try XCTUnwrap(analyticsService.crashesLogged.first as? SecureStoreErrorV2)
        XCTAssert(error.kind == .unableToRetrieveFromUserDefaults)
        XCTAssertFalse(sessionManager.didCallClearAllSessionData)
        XCTAssertEqual(sessionState, .localAuthCancelled)
    }
    
    @MainActor
    func test_resumeSession_secureStoreError_keepsSessionData() {
        let sessionManager = MockSessionManager()
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = SecureStoreErrorV2(.cantDecryptData)
        let sut: AppQualifyingService = .make(sessionManager: sessionManager)

        let (appState, sessionState) = waitForAppInfoStateChange(sut: sut, when: { sut in
            sut.initiate()
        })
        
        XCTAssertEqual(appState, .qualified)
        XCTAssertNotEqual(sessionState, .failed(MockWalletError.cantDelete))
    }
    
    @MainActor
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
    
    @MainActor
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
    
    @MainActor
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
    
    @MainActor
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
}

// MARK: - Subscription Tests
extension AppQualifyingServiceTests {
    
    @MainActor
    func test_enrolmentComplete_changesSessionState() {
        let appInformationProvider = MockAppInformationService()
        appInformationProvider.errorFromFetchAppInfo = AppInfoError.invalidResponse
        let sut: AppQualifyingService = .make(appInformationProvider: appInformationProvider)

        let (_, sessionState) = waitForSessionStateChange(sut: sut, when: { _ in
            NotificationCenter.default.post(name: .enrolmentComplete)
        })
        
        XCTAssertEqual(sessionState, .loggedIn)
    }
    
    @MainActor
    func test_sessionExpiry_changesSessionState() {
        let appInformationProvider = MockAppInformationService()
        appInformationProvider.errorFromFetchAppInfo = AppInfoError.invalidResponse
        let sut: AppQualifyingService = .make(appInformationProvider: appInformationProvider)

        let (_, sessionState) = waitForSessionStateChange(sut: sut, when: { _ in
            NotificationCenter.default.post(name: .sessionExpired)
        })
        
        XCTAssertEqual(sessionState, .expired)
    }
    
    @MainActor
    func test_logOut_changesSessionState() {
        let appInformationProvider = MockAppInformationService()
        appInformationProvider.errorFromFetchAppInfo = AppInfoError.invalidResponse
        let sut: AppQualifyingService = .make(appInformationProvider: appInformationProvider)

        let (_, sessionState) = waitForSessionStateChange(sut: sut, when: { _ in
            NotificationCenter.default.post(name: .systemLogUserOut)
        })
        
        XCTAssertEqual(sessionState, .systemLogOut)
    }
    
    @MainActor
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
}
