@testable import OneLogin
import SecureStore
import XCTest

final class AppQualifyingServiceTests: XCTestCase {
    private var analyticsService: MockAnalyticsService!
    private var sessionManager: MockSessionManager!
    private var appInformationProvider: MockAppInformationService!
    private var sut: AppQualifyingService!

    private var appState: AppInformationState?
    private var userState: AppLocalAuthState?

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
        userState = nil

        sut = nil

        AppEnvironment.updateReleaseFlags([:])

        super.tearDown()
    }
}

// MARK: - App Info Requests
extension AppQualifyingServiceTests {
    func testAppInfoIsRequested() {
        sut.initiate()

        waitForTruth(
            self.appInformationProvider.didCallFetchAppInfo,
            timeout: 5
        )
    }

    func testUpToDateApp_setsStateCorrectly() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sut.delegate = self
        sut.initiate()

        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )

        XCTAssertEqual(AppEnvironment.releaseFlags.flags, releaseFlags)
    }

    func testOutdatedApp_setsStateCorrectly() {
        // GIVEN the app is outdated
        appInformationProvider.currentVersion = .init(.min, .min, .min)

        sut.delegate = self
        sut.initiate()

        waitForTruth(
            self.appState == .outdated,
            timeout: 5
        )
    }

    func testOfflineApp_setsStateCorrectly() {
        // GIVEN the app is offline
        appInformationProvider.shouldReturnError = true

        sut.delegate = self
        sut.initiate()

        waitForTruth(
            self.appState == .offline,
            timeout: 5
        )
    }

    func testErrorThrown_setsStateCorrectly() {
        // GIVEN `appInfo` cannot be accessed
        appInformationProvider.shouldReturnError = true
        appInformationProvider.errorToThrow = URLError(.timedOut)

        sut.delegate = self
        sut.initiate()

        // THEN the error state is set
        waitForTruth(
            self.appState == .error,
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
        sut.initiate()

        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )
        
        XCTAssert(self.userState == .loggedIn)
    }
    
    func testNoExpiryDate_userUnconfirmed() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )
        
        XCTAssert(self.userState == .notLoggedIn)
    }
    
    func testSessionInvalid_userExpired() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sessionManager.expiryDate = .distantFuture
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )
        
        XCTAssert(self.userState == .expired)
    }
    
    func testResumeSession_userConfirmed() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sessionManager.expiryDate = .distantFuture
        sessionManager.isSessionValid = true
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )
        
        XCTAssert(self.userState == .loggedIn)
    }
    
    func testResumeSession_cantDecryptData_error() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sessionManager.expiryDate = .distantFuture
        sessionManager.isSessionValid = true
        sessionManager.errorFromResumeSession = SecureStoreError.cantDecryptData
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )
        
        XCTAssertNil(self.userState)
    }
    
    func testResumeSession_nonCantDecryptData_error() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sessionManager.expiryDate = .distantFuture
        sessionManager.isSessionValid = true
        sessionManager.errorFromResumeSession = SecureStoreError.unableToRetrieveFromUserDefaults
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )

        XCTAssert(analyticsService.crashesLogged.first as? SecureStoreError == .unableToRetrieveFromUserDefaults)
        XCTAssert(sessionManager.didCallEndCurrentSession)
        XCTAssert(self.userState == .notLoggedIn)
    }
    
    func testResumeSession_nonCantDecryptData_error_clearSessionData_error() {
        let releaseFlags = ["TestFlag": true]
        appInformationProvider.releaseFlags = releaseFlags
        sessionManager.expiryDate = .distantFuture
        sessionManager.isSessionValid = true
        sessionManager.errorFromResumeSession = SecureStoreError.unableToRetrieveFromUserDefaults
        sessionManager.errorFromClearAllSessionData = MockWalletError.cantDelete
        sut.delegate = self
        sut.initiate()
        
        waitForTruth(
            self.appState == .qualified,
            timeout: 5
        )
        
        XCTAssert(self.userState == .failed(MockWalletError.cantDelete))
    }
}

// MARK: - Subscription Tests
extension AppQualifyingServiceTests {
    func testEnrolmentComplete_changesUserState() {
        appInformationProvider.shouldReturnError = true
        sut.delegate = self
        sut.initiate()

        NotificationCenter.default.post(name: .enrolmentComplete)
        waitForTruth(self.userState == .loggedIn, timeout: 5)
    }

    func testSessionExpiry_changesUserState() {
        appInformationProvider.shouldReturnError = true
        sut.delegate = self
        sut.initiate()

        NotificationCenter.default.post(name: .sessionExpired)
        waitForTruth(self.userState == .expired, timeout: 5)
    }

    func testLogout_changesUserState() {
        appInformationProvider.shouldReturnError = true
        sut.delegate = self
        sut.initiate()
        
        NotificationCenter.default.post(name: .didLogout)
        waitForTruth(self.userState == .notLoggedIn, timeout: 5)
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
