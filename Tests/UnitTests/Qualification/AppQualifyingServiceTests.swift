import MobilePlatformServices
@testable import OneLogin
import SecureStore
import XCTest

final class AppQualifyingServiceTests: XCTestCase {
    private var analyticsService: MockAnalyticsService!
    private var sessionManager: MockSessionManager!
    private var appInformationProvider: MockAppInformationService!
    private var sut: AppQualifyingService!

    private var appState: AppInformationState?
    private var sessionState: AppSessionState?

    override func setUp() {
        super.setUp()


        analyticsService = MockAnalyticsService()
        sessionManager = MockSessionManager()
        appInformationProvider = MockAppInformationService()
        sut = AppQualifyingService(analyticsService: analyticsService,
                                   updateService: appInformationProvider,
                                   sessionManager: sessionManager)
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
    
    func test_resumeSession_userCancelledBiometrics_error() {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = SecureStoreError(.biometricsCancelled)
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )
        
        XCTAssert(self.sessionState == .localAuthCancelled)
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
    
    func test_resumeSession_nonCantDecryptData_error() throws {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = SecureStoreError(.unableToRetrieveFromUserDefaults)
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )

        let error = try XCTUnwrap(analyticsService.crashesLogged.first as? SecureStoreError)
        XCTAssert(error.kind == .unableToRetrieveFromUserDefaults)
        XCTAssert(sessionManager.didCallClearAllSessionData)
        XCTAssert(self.sessionState == .systemLogOut)
    }
    
    func test_resumeSession_nonCantDecryptData_error_clearSessionData_error() {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = SecureStoreError(.unableToRetrieveFromUserDefaults)
        sessionManager.errorFromClearAllSessionData = MockWalletError.cantDelete
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )
        
        XCTAssert(self.sessionState == .failed(MockWalletError.cantDelete))
    }
    
    func test_resumeSession_noPersistentSessionError_clearSessionDaat() {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = PersistentSessionError.noSessionExists
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )

        XCTAssert(analyticsService.crashesLogged.first as? PersistentSessionError == .noSessionExists)
        XCTAssert(sessionManager.didCallClearAllSessionData)
        XCTAssert(self.sessionState == .systemLogOut)
    }
    
    func test_resumeSession_idTokenNotStoredError_clearSessionDaat() {
        sessionManager.expiryDate = .distantFuture
        sessionManager.sessionState = .saved
        sessionManager.errorFromResumeSession = PersistentSessionError.idTokenNotStored
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )

        XCTAssert(analyticsService.crashesLogged.first as? PersistentSessionError == .idTokenNotStored)
        XCTAssert(sessionManager.didCallClearAllSessionData)
        XCTAssert(self.sessionState == .systemLogOut)
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
}
