import Coordination
import Networking
@testable import OneLogin
import XCTest

final class QualifyingCoordinatorTests: XCTestCase {
    private var sessionManager: MockSessionManager!
    private var networkClient: NetworkClient!
    private var qualifyingService: MockQualifyingService!
    private var analyticsCenter: MockAnalyticsCenter!
    private var window: UIWindow!

    private var sut: QualifyingCoordinator!

    @MainActor
    override func setUp() {
        super.setUp()

        window = UIWindow()

        analyticsCenter = MockAnalyticsCenter(
            analyticsService: MockAnalyticsService(),
            analyticsPreferenceStore: MockAnalyticsPreferenceStore()
        )

        sessionManager = MockSessionManager()
        qualifyingService = MockQualifyingService()

        networkClient = NetworkClient()

        sut = QualifyingCoordinator(window: window,
                                    analyticsCenter: analyticsCenter,
                                    appQualifyingService: qualifyingService,
                                    sessionManager: sessionManager,
                                    networkClient: networkClient)
    }

    override func tearDown() {
        sessionManager = nil
        networkClient = nil
        qualifyingService = nil
        analyticsCenter = nil
        window = nil

        super.tearDown()
    }
}

extension QualifyingCoordinatorTests {
    @MainActor
    func test_start_displaysLoadingScreen() throws {
        // GIVEN I open the app
        sut.start()
        // THEN I am shown the loading screen
        _ = try XCTUnwrap(
            window.rootViewController as? UnlockScreenViewController
        )
    }

    @MainActor
    func test_unconfirmedApp_remainsOnLoadingScreen() {
        // GIVEN I reopen the app
        // WHEN I have not yet received a result from `appInfo`
        sut.didChangeAppInfoState(state: .appUnconfirmed)
        // THEN I remain on the loading screen

    }

    @MainActor
    func test_outdatedApp_displaysUpdateAppScreen() {
        // GIVEN I reopen the app
        // WHEN I have not yet received a result from `appInfo`
        sut.didChangeAppInfoState(state: .appOutdated)
        // THEN I remain on the loading screen
        
    }
}
// @MainActor
// func test_evaluateRevisit_requiresNewUserToLogin() throws {
//    // GIVEN the app has token information stored and the accessToken is valid
//    try mockSessionManager.setupSession(returningUser: false, expired: true)
//    // WHEN the MainCoordinator's evaluateRevisit method is called
//    sut.evaluateRevisit()
//    // THEN the session manager should end the current session
//    XCTAssertTrue(mockSessionManager.didCallEndCurrentSession)
//    XCTAssertTrue(sut.childCoordinators.last is LoginCoordinator)
// }
//
// @MainActor
// func test_evaluateRevisit_requiresExpiredUserToLogin() throws {
//    // GIVEN the app has token information stored but the accessToken is expired
//    try mockSessionManager.setupSession(expired: true)
//    // WHEN the MainCoordinator's evaluateRevisit method is called
//    sut.evaluateRevisit()
//    // THEN the session manager should end the current session
//    XCTAssertTrue(mockSessionManager.didCallEndCurrentSession)
//    XCTAssertTrue(sut.childCoordinators.last is LoginCoordinator)
// }
//
// @MainActor
// func test_evaluateRevisit_showsHomeScreenForExistingSession() throws {
//    // GIVEN the app has token information store and the accessToken is valid
//    try mockSessionManager.setupSession(returningUser: true)
//    // WHEN the MainCoordinator's evaluateRevisit method is called
//    sut.evaluateRevisit()
//    // THEN the session manager should resume the current session
//    waitForTruth(self.mockSessionManager.didCallResumeSession, timeout: 20)
//    XCTAssertFalse(sut.childCoordinators.last is LoginCoordinator)
// }
//
// @MainActor
// func test_evaluateRevisit_extractIdTokenPayload_JWTVerifierError() throws {
//    // GIVEN the app has token information store and the accessToken is valid
//    try mockSessionManager.setupSession(returningUser: true)
//    // GIVEN the token verifier throws an invalidJWTFormat error
//    mockSessionManager.errorFromResumeSession = JWTVerifierError.invalidJWTFormat
//    // WHEN the MainCoordinator's evaluateRevisit method is called
//    sut.evaluateRevisit()
//    // THEN the session manager should end the current session
//    waitForTruth(self.mockSessionManager.didCallResumeSession, timeout: 20)
//    // THEN the login coordinator should contain that error
//    let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
//    let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? JWTVerifierError)
//    XCTAssertTrue(loginCoordinatorError == .invalidJWTFormat)
// }
//
// @MainActor
// func test_evaluateRevisit_readFromSecureStore_SecureStoreError_unableToRetrieveFromUserDefaults() throws {
//    // GIVEN the app has token information store and the accessToken is valid
//    try mockSessionManager.setupSession(returningUser: true)
//    // GIVEN the secure store throws an unableToRetrieveFromUserDefaults error
//    mockSessionManager.errorFromResumeSession = SecureStoreError.unableToRetrieveFromUserDefaults
//    // WHEN the MainCoordinator's evaluateRevisit method is called
//    sut.evaluateRevisit()
//    // THEN the session manager should end the current session
//    waitForTruth(self.mockSessionManager.didCallResumeSession, timeout: 20)
//    // THEN the login coordinator should contain that error
//    let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
//    let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? SecureStoreError)
//    XCTAssertTrue(loginCoordinatorError == .unableToRetrieveFromUserDefaults)
// }
//
// @MainActor
// func test_evaluateRevisit_readFromSecureStore_SecureStoreError_cantInitialiseData() throws {
//    // GIVEN the app has token information store and the accessToken is valid
//    try mockSessionManager.setupSession(returningUser: true)
//    // GIVEN the secure store throws an cantInitialiseData error
//    mockSessionManager.errorFromResumeSession = SecureStoreError.cantInitialiseData
//    // WHEN the MainCoordinator's evaluateRevisit method is called
//    sut.evaluateRevisit()
//    // THEN the session manager should end the current session
//    waitForTruth(self.mockSessionManager.didCallResumeSession, timeout: 20)
//    // THEN the login coordinator should contain that error
//    let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
//    let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? SecureStoreError)
//    XCTAssertTrue(loginCoordinatorError == .cantInitialiseData)
// }
//
// @MainActor
// func test_evaluateRevisit_readFromSecureStore_SecureStoreError_cantRetrieveKey() throws {
//    // GIVEN the app has token information store and the accessToken is valid
//    try mockSessionManager.setupSession(returningUser: true)
//    // GIVEN the secure store throws an cantRetrieveKey error
//    mockSessionManager.errorFromResumeSession = SecureStoreError.cantRetrieveKey
//    // WHEN the MainCoordinator's evaluateRevisit method is called
//    sut.evaluateRevisit()
//    // THEN the session manager should end the current session
//    waitForTruth(self.mockSessionManager.didCallResumeSession, timeout: 20)
//    // THEN the login coordinator should contain that error
//    let loginCoordinator = try XCTUnwrap(sut.childCoordinators.first as? LoginCoordinator)
//    let loginCoordinatorError = try XCTUnwrap(loginCoordinator.loginError as? SecureStoreError)
//    XCTAssertTrue(loginCoordinatorError == .cantRetrieveKey)
// }
//
// @MainActor
// func test_evaluateRevisit_readFromSecureStore_SecureStoreError_cantDecryptData() throws {
//    // GIVEN the app has token information store and the accessToken is valid
//    try mockSessionManager.setupSession(returningUser: true)
//    // GIVEN the secure store throws an cantDecryptData error
//    mockSessionManager.errorFromResumeSession = SecureStoreError.cantDecryptData
//    // WHEN the MainCoordinator's evaluateRevisit method is called
//    sut.evaluateRevisit()
//    // THEN the session manager should not end the current session
//    XCTAssertFalse(mockSessionManager.didCallEndCurrentSession)
//    // THEN no coordinator should be launched
//    XCTAssertEqual(sut.childCoordinators.count, 0)
// }
