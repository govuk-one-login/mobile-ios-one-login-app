@testable import OneLogin
import SecureStore
import XCTest

final class AppQualifyingServiceTests: XCTestCase {
    private lazy var sut: AppQualifyingService! = {
        AppQualifyingService(updateService: appInformationProvider,
                             sessionManager: sessionManager)
    }()

    private var sessionManager: MockSessionManager!
    private var appInformationProvider: MockAppInformationService!

    private var appState: AppInformationState?
    private var userState: AppLocalAuthState?

    override func setUp() {
        super.setUp()

        sessionManager = MockSessionManager()
        appInformationProvider = MockAppInformationService()
    }

    override func tearDown() {
        sessionManager = nil
        appInformationProvider = nil

        appState = nil
        userState = nil

        sut = nil

        AppEnvironment.updateReleaseFlags([:])

        super.tearDown()
    }
}

// MARK: - App Info Requests
extension AppQualifyingServiceTests {
    func testAppInfoIsRequested() {
        _ = sut

        waitForTruth(
            self.appInformationProvider.didCallFetchAppInfo,
            timeout: 5
        )
    }

    func testUpToDateApp_setsStateCorrectly() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sut.delegate = self

        waitForTruth(
            self.appState == .appConfirmed,
            timeout: 5
        )

        XCTAssertEqual(AppEnvironment.releaseFlags.flags, releaseFlags)
    }

    func testOutdatedApp_setsStateCorrectly() {
        // GIVEN the app is outdated
        appInformationProvider.currentVersion = .init(.min, .min, .min)

        sut.delegate = self

        waitForTruth(
            self.appState == .appOutdated,
            timeout: 5
        )
    }

    func testOfflineApp_setsStateCorrectly() {
        // GIVEN the app is offline
        appInformationProvider.shouldReturnError = true

        sut.delegate = self

        waitForTruth(
            self.appState == .appOffline,
            timeout: 5
        )
    }

    func testErrorThrown_setsStateCorrectly() {
        // GIVEN `appInfo` cannot be accessed
        appInformationProvider.shouldReturnError = true
        appInformationProvider.errorToThrow = URLError(.timedOut)

        sut.delegate = self

        // THEN the error state is set
        waitForTruth(
            self.appState == .appInfoError,
            timeout: 5
        )
    }
}

// MARK: - User State Evaluation
extension AppQualifyingServiceTests {
    func testOneTimeUser_userConfirmed() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sessionManager.isOneTimeUser = true
        sut.delegate = self

        waitForTruth(
            self.appState == .appConfirmed,
            timeout: 5
        )
        
        XCTAssert(self.userState == .userConfirmed)
    }
    
    func testNoExpiryDate_userUnconfirmed() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sut.delegate = self
        
        waitForTruth(
            self.appState == .appConfirmed,
            timeout: 5
        )
        
        XCTAssert(self.userState == .userUnconfirmed)
    }
    
    func testSessionInvalid_userExpired() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sessionManager.expiryDate = .distantFuture
        sut.delegate = self
        
        waitForTruth(
            self.appState == .appConfirmed,
            timeout: 5
        )
        
        XCTAssert(self.userState == .userExpired)
    }
    
    func testResumeSession_userConfirmed() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sessionManager.expiryDate = .distantFuture
        sessionManager.isSessionValid = true
        sut.delegate = self
        
        waitForTruth(
            self.appState == .appConfirmed,
            timeout: 5
        )
        
        XCTAssert(self.userState == .userConfirmed)
    }
    
    func testResumeSession_cantDecryptData_error() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sessionManager.expiryDate = .distantFuture
        sessionManager.isSessionValid = true
        sessionManager.errorFromResumeSession = SecureStoreError.cantDecryptData
        sut.delegate = self
        
        waitForTruth(
            self.appState == .appConfirmed,
            timeout: 5
        )
        
        XCTAssertNil(self.userState)
    }
    
    func testResumeSession_nonCantDecryptData_error() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sessionManager.expiryDate = .distantFuture
        sessionManager.isSessionValid = true
        sessionManager.errorFromResumeSession = JWTVerifierError.invalidJWTFormat
        sut.delegate = self
        
        waitForTruth(
            self.appState == .appConfirmed,
            timeout: 5
        )
        
        XCTAssert(sessionManager.didCallEndCurrentSession)
        XCTAssert(self.userState == .userUnconfirmed)
    }
    
    func testResumeSession_nonCantDecryptData_error_clearSessionData_error() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sessionManager.expiryDate = .distantFuture
        sessionManager.isSessionValid = true
        sessionManager.errorFromResumeSession = JWTVerifierError.invalidJWTFormat
        sessionManager.errorFromClearAllSessionData = MockWalletError.cantDelete
        sut.delegate = self
        
        waitForTruth(
            self.appState == .appConfirmed,
            timeout: 5
        )
        
        XCTAssert(self.userState == .userFailed(JWTVerifierError.invalidJWTFormat))
    }
}

// MARK: - Subscription Tests
extension AppQualifyingServiceTests {
    func testEnrolmentComplete_changesUserState() {
        appInformationProvider.shouldReturnError = true
        sut.delegate = self

        NotificationCenter.default.post(name: .enrolmentComplete)
        waitForTruth(self.userState == .userConfirmed, timeout: 5)
    }

    func testSessionExpiry_changesUserState() {
        appInformationProvider.shouldReturnError = true
        sut.delegate = self

        NotificationCenter.default.post(name: .sessionExpired)
        waitForTruth(self.userState == .userExpired, timeout: 5)
    }

    func testLogout_changesUserState() {
        appInformationProvider.shouldReturnError = true
        sut.delegate = self
        
        NotificationCenter.default.post(name: .didLogout)
        waitForTruth(self.userState == .userUnconfirmed, timeout: 5)
    }
}

extension AppQualifyingServiceTests: AppQualifyingServiceDelegate {
    func didChangeAppInfoState(state appInfoState: AppInformationState) {
        self.appState = appInfoState
    }
    
    func didChangeUserState(state userState: AppLocalAuthState) {
        self.userState = userState
    }
}
