// swiftlint:disable file_length
import MobilePlatformServices
import Networking
@testable import OneLogin
import SecureStore
import XCTest
import AppIntegrity

final class AppQualifyingServiceTests: XCTestCase {
    private var analyticsService: MockAnalyticsService!
    private var sessionManager: MockSessionManager!
    private var appInformationProvider: MockAppInformationService!
    private var sut: AppQualifyingService!

    private var appState: AppInformationState?
    private var sessionState: AppSessionState?
    private var serviceState: RemoteServiceState?

    override func setUp() {
        super.setUp()


        analyticsService = MockAnalyticsService()
        sessionManager = MockSessionManager()
        appInformationProvider = MockAppInformationService()
        sut = AppQualifyingService(analyticsService: analyticsService,
                                   updateService: appInformationProvider,
                                   sessionManager: sessionManager,
        appIntegrityProvider: AppIntegrityProviderStub())
    }

    override func tearDown() {
        analyticsService = nil
        sessionManager = nil
        appInformationProvider = nil

        appState = nil
        sessionState = nil

        sut = nil

        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [:]
        )
        super.tearDown()
    }
}

// MARK: - App Info Requests
extension AppQualifyingServiceTests {
    func test_appInfoIsRequested() {
        sut.initiate()

        waitForTruth(
            self.appInformationProvider.didCallFetchAppInfo,
            timeout: 5
        )
    }
    
    func test_appUnavailable_setsStateCorrectly() {
        // GIVEN app usage is not allowed
        appInformationProvider.allowAppUsage = false

        sut.delegate = self
        sut.initiate()

        // THEN the unavailable state is set
        waitForTruth(
            self.appState == .unavailable,
            timeout: 5
        )
    }

    
    func test_outdatedApp_setsStateCorrectly() {
        // GIVEN the app is outdated
        appInformationProvider.currentVersion = .init(.min, .min, .min)

        sut.delegate = self
        sut.initiate()

        // THEN the outdated state is set
        waitForTruth(
            self.appState == .outdated,
            timeout: 5
        )
    }

    func test_upToDateApp_setsStateCorrectly() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sut.delegate = self
        sut.initiate()

        // THEN the qualified state is set
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )

        XCTAssertEqual(AppEnvironment.remoteReleaseFlags.flags, releaseFlags)
    }

    func test_errorThrown_setsStateCorrectly() {
        // GIVEN `appInfo` cannot be accessed
        appInformationProvider.errorFromFetchAppInfo = URLError(.timedOut)

        sut.delegate = self
        sut.initiate()

        // THEN the error state is set
        waitForTruth(
            self.appState == .error,
            timeout: 5
        )
    }
    
    func test_appInfoOfflineError_setsStateCorrectly() {
        // GIVEN the app is offline
        appInformationProvider.errorFromFetchAppInfo = AppInfoError.notConnectedToInternet

        sut.delegate = self
        sut.initiate()

        // THEN the offline state is set
        waitForTruth(
            self.appState == .offline,
            timeout: 5
        )
    }
    
    func test_accountIntervention_returns() {
        // GIVEN the a receives an account intervention
        appInformationProvider.errorFromFetchAppInfo = ServerError(endpoint: "test", errorCode: 400)

        sut.delegate = self
        sut.initiate()

        // THEN the original session state is maintained
        waitForTruth(
            self.sessionState == nil,
            timeout: 5
        )
    }
    
    func test_appInfoInvalidError_setsStateCorrectly() {
        appInformationProvider.errorFromFetchAppInfo = AppInfoError.invalidResponse
        
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .unavailable,
            timeout: 5
        )
    }
}

// MARK: - User State Evaluation
extension AppQualifyingServiceTests {
    func test_oneTimeUser_userConfirmed() {
        sessionManager.sessionState = .oneTime
        sut.delegate = self
        sut.initiate()

        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )
        
        XCTAssert(self.sessionState == .loggedIn)
    }
    
    func test_noExpiryDate_userUnconfirmed() {
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )
        
        XCTAssert(self.sessionState == .notLoggedIn)
    }
    
    func test_sessionInvalid_userExpired() {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .expired
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )
        
        XCTAssert(self.sessionState == .expired)
    }
    
    func test_resumeSession_userConfirmed() {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )
        
        XCTAssert(self.sessionState == .loggedIn)
    }
    
    func test_resumeSession_noInternet_error() {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = RefreshTokenExchangeError.noInternet
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .offline,
            timeout: 5
        )
    }
    
    func test_resumeSession_appIntegrityFailed() {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = RefreshTokenExchangeError.appIntegrityFailed
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.sessionState == .appIntegrityCheckFailed,
            timeout: 5
        )
    }
    
    func test_resumeSession_accountIntervention() throws {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = ServerError(endpoint: "test", errorCode: 400)
        sut.delegate = self
        sut.initiate()
        
        // THEN the original session state is maintained
        waitForTruth(
            self.sessionState == nil,
            timeout: 5
        )
        
        let error = try XCTUnwrap(analyticsService.crashesLogged.first as? ServerError)
        XCTAssert(error.errorCode == 400)
    }
    
    func test_resumeSession_secureStoreError_cantDecryptData() {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = SecureStoreErrorV2(.cantDecryptData)
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )
        
        XCTAssert(self.sessionState == .expired)
    }
    
    func test_resumeSession_secureStoreError() throws {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = SecureStoreErrorV2(.unableToRetrieveFromUserDefaults)
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )

        let error = try XCTUnwrap(analyticsService.crashesLogged.first as? SecureStoreErrorV2)
        XCTAssert(error.kind == .unableToRetrieveFromUserDefaults)
        XCTAssertFalse(sessionManager.didCallClearAllSessionData)
        XCTAssert(self.sessionState == .localAuthCancelled)
    }
    
    func test_resumeSession_secureStoreError_keepsSessionData() {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = SecureStoreErrorV2(.unableToRetrieveFromUserDefaults)
        sessionManager.errorFromClearAllSessionData = MockWalletError.cantDelete
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )
        
        XCTAssertFalse(self.sessionState == .failed(MockWalletError.cantDelete))
    }
    
    func test_resumeSession_userRemovedLocalAuth_clearSessionData() {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = PersistentSessionError(.userRemovedLocalAuth)
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )

        XCTAssert(analyticsService.crashesLogged.first as? PersistentSessionError == PersistentSessionError(.userRemovedLocalAuth))
        XCTAssert(sessionManager.didCallClearAllSessionData)
        XCTAssert(self.sessionState == .systemLogOut)
    }
    
    func test_resumeSession_noPersistentSessionError_clearSessionData() {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = PersistentSessionError(.noSessionExists)
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )

        XCTAssert(analyticsService.crashesLogged.first as? PersistentSessionError == PersistentSessionError(.noSessionExists))
        XCTAssert(sessionManager.didCallClearAllSessionData)
        XCTAssert(self.sessionState == .systemLogOut)
    }
    
    func test_resumeSession_idTokenNotStoredError_clearSessionData() {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = PersistentSessionError(.idTokenNotStored)
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )

        XCTAssert(analyticsService.crashesLogged.first as? PersistentSessionError == PersistentSessionError(.idTokenNotStored))
        XCTAssert(sessionManager.didCallClearAllSessionData)
        XCTAssert(self.sessionState == .systemLogOut)
    }
    
    func test_resumeSession_idTokenNotStoredError_clearSessionDataFails() {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = PersistentSessionError(.idTokenNotStored)
        sessionManager.errorFromClearAllSessionData = MockWalletError.cantDelete
        
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )
        
        XCTAssert(analyticsService.crashesLogged.first as? PersistentSessionError == PersistentSessionError(.idTokenNotStored))
        XCTAssert(sessionManager.didCallClearAllSessionData)
        XCTAssert(self.sessionState == .failed(MockWalletError.cantDelete))
    }
}

// MARK: - Subscription Tests
extension AppQualifyingServiceTests {
    func test_enrolmentComplete_changesSessionState() {
        appInformationProvider.errorFromFetchAppInfo = AppInfoError.invalidResponse
        sut.delegate = self
        sut.initiate()

        NotificationCenter.default.post(name: .enrolmentComplete)
        waitForTruth(self.sessionState == .loggedIn, timeout: 5)
    }
    
    func test_sessionExpiry_changesSessionState() {
        appInformationProvider.errorFromFetchAppInfo = AppInfoError.invalidResponse
        sut.delegate = self
        sut.initiate()

        NotificationCenter.default.post(name: .sessionExpired)
        waitForTruth(self.sessionState == .expired, timeout: 5)
    }
    
    func test_logOut_changesSessionState() {
        appInformationProvider.errorFromFetchAppInfo = AppInfoError.invalidResponse
        sut.delegate = self
        sut.initiate()
        
        NotificationCenter.default.post(name: .systemLogUserOut)
        waitForTruth(self.sessionState == .systemLogOut, timeout: 5)
    }
}

extension AppQualifyingServiceTests: AppQualifyingServiceDelegate {
    func didChangeAppInfoState(state appInfoState: AppInformationState) {
        self.appState = appInfoState
    }
    
    func didChangeSessionState(state sessionState: AppSessionState) {
        self.sessionState = sessionState
    }
    
    func didChangeServiceState(state serviceState: RemoteServiceState) {
        self.serviceState = serviceState
    }
}
