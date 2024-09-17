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
    private var authState: AppLocalAuthState?

    override func setUp() {
        super.setUp()

        sessionManager = MockSessionManager()
        appInformationProvider = MockAppInformationService()
    }

    override func tearDown() {
        sessionManager = nil
        appInformationProvider = nil

        appState = nil
        authState = nil

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
        
        XCTAssert(self.authState == .userConfirmed)
    }
    
    func testNoExpiryDate_userUnconfirmed() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sut.delegate = self
        
        waitForTruth(
            self.appState == .appConfirmed,
            timeout: 5
        )
        
        XCTAssert(self.authState == .userUnconfirmed)
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
        
        XCTAssert(self.authState == .userExpired)
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
        
        XCTAssert(self.authState == .userConfirmed)
    }
    
    func testResumeSession_cantDecryptData() {
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
        
        XCTAssertNil(self.authState)
    }
    
    func testResumeSession_invalidJWTFormat_userFailed() {
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
        
        XCTAssert(self.authState == .userFailed(JWTVerifierError.invalidJWTFormat))
    }
    
    func testResumeSession_unableToRetrieveFromUserDefaults_userFailed() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sessionManager.expiryDate = .distantFuture
        sessionManager.isSessionValid = true
        sessionManager.errorFromResumeSession = SecureStoreError.unableToRetrieveFromUserDefaults
        sut.delegate = self
        
        waitForTruth(
            self.appState == .appConfirmed,
            timeout: 5
        )
        
        XCTAssert(self.authState == .userFailed(SecureStoreError.unableToRetrieveFromUserDefaults))
    }
    
    func testResumeSession_cantInitialiseData_userFailed() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sessionManager.expiryDate = .distantFuture
        sessionManager.isSessionValid = true
        sessionManager.errorFromResumeSession = SecureStoreError.cantInitialiseData
        sut.delegate = self
        
        waitForTruth(
            self.appState == .appConfirmed,
            timeout: 5
        )
        
        XCTAssert(self.authState == .userFailed(SecureStoreError.cantInitialiseData))
    }
    
    func testResumeSession_cantRetrieveKey_userFailed() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sessionManager.expiryDate = .distantFuture
        sessionManager.isSessionValid = true
        sessionManager.errorFromResumeSession = SecureStoreError.cantRetrieveKey
        sut.delegate = self
        
        waitForTruth(
            self.appState == .appConfirmed,
            timeout: 5
        )
        
        XCTAssert(self.authState == .userFailed(SecureStoreError.cantRetrieveKey))
    }
}

// MARK: - Subscription Tests
extension AppQualifyingServiceTests {
    func testEnrolmentComplete_changesUserState() {
        appInformationProvider.shouldReturnError = true
        sut.delegate = self

        NotificationCenter.default.post(name: .enrolmentComplete)
        waitForTruth(self.authState == .userConfirmed, timeout: 5)
    }

    func testSessionExpiry_changesUserState() {
        appInformationProvider.shouldReturnError = true
        sut.delegate = self

        NotificationCenter.default.post(name: .sessionExpired)
        waitForTruth(self.authState == .userExpired, timeout: 5)
    }

    func testLogout_changesUserState() {
        appInformationProvider.shouldReturnError = true
        sut.delegate = self
        
        NotificationCenter.default.post(name: .didLogout)
        waitForTruth(self.authState == .userUnconfirmed, timeout: 5)
    }
}

extension AppQualifyingServiceTests: AppQualifyingServiceDelegate {
    func didChangeAppInfoState(state appInfoState: AppInformationState) {
        appState = appInfoState
    }
    
    func didChangeUserState(state userState: AppLocalAuthState) {
        authState = userState
    }
}
