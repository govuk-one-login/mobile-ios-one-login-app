import Coordination
import GDSCommon
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
// MARK: - App State updates
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
    func test_unconfirmedApp_remainsOnLoadingScreen() throws {
        // GIVEN I reopen the app
        // WHEN I have not yet received a result from `appInfo`
        sut.didChangeAppInfoState(state: .appUnconfirmed)
        // THEN I remain on the loading screen
        _ = try XCTUnwrap(
            window.rootViewController as? UnlockScreenViewController
        )
    }

    @MainActor
    func test_outdatedApp_displaysUpdateAppScreen() throws {
        // GIVEN I reopen the app
        // WHEN I receive an App outdated result from `appInfo`
        sut.didChangeAppInfoState(state: .appOutdated)
        // THEN I am shown the Update Required screen
        let vc = try XCTUnwrap(
            window.rootViewController as? GDSInformationViewController
        )
        XCTAssertTrue(vc.viewModel is UpdateAppViewModel)
    }
}
// MARK: - User State updates
extension QualifyingCoordinatorTests {
    @MainActor
    func test_confirmedUser_displaysMainView() throws {
        // GIVEN I reopen the app
        // WHEN I authenticate as a valid user
        sut.didChangeUserState(state: .userConfirmed)
        // THEN I am shown the Main View
        let mainCoordinator = try XCTUnwrap(sut.childCoordinators
            .compactMap { $0 as? MainCoordinator }
            .first)
        XCTAssertIdentical(window.rootViewController, mainCoordinator.root)
    }

    @MainActor
    func test_unconfirmedUser_seesTheLoginScreen() throws {
        // GIVEN I reopen the app
        // WHEN I have no session
        sut.didChangeUserState(state: .userUnconfirmed)
        // THEN I am shown the Login Coordinator
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators
            .compactMap { $0 as? LoginCoordinator }
            .first)
        XCTAssertIdentical(window.rootViewController, loginCoordinator.root)
    }

    @MainActor
    func test_expiredUser_seesTheLoginScreen() throws {
        // GIVEN I reopen the app
        // WHEN my session has expired
        sut.didChangeUserState(state: .userExpired)
        // THEN I am shown the Login Coordinator
        let loginCoordinator = try XCTUnwrap(sut.childCoordinators
            .compactMap { $0 as? LoginCoordinator }
            .first)
        XCTAssertIdentical(window.rootViewController, loginCoordinator.root)
    }

    @MainActor
    func test_failedUser_seesTheUnableToLoginScreen() throws {
        // GIVEN I reopen the app
        // WHEN I fail to login
        enum MockLoginError: Error, LocalizedError {
            case failed

            var errorDescription: String? {
                "Unable to login"
            }
        }

        sut.didChangeUserState(state: .userFailed(MockLoginError.failed))
        // THEN I am shown the Login Error screen
        let vc = try XCTUnwrap(
            window.rootViewController as? GDSErrorViewController
        )
        let viewModel = try XCTUnwrap(vc.viewModel as? UnableToLoginErrorViewModel)
        XCTAssertEqual(viewModel.errorDescription, "Unable to login")

    }

    // TODO: DCMAW-9866 | incorporate these tests into this class:
    // @MainActor
    // func test_evaluateRevisit_whenLocalAuthRemoved() throws {
    //    // GIVEN the app has token information stored and the accessToken is valid
    //    try mockSessionManager.setupSession(returningUser: true, expired: false)
    //    // WHEN local auth is removed
    //    mockSessionManager.errorFromResumeSession = PersistentSessionError.userRemovedLocalAuth
    //    // AND the MainCoordinator's evaluateRevisit method is called
    //    sut.evaluateRevisit()
    //    // THEN the session manager should end the current session
    //    waitForTruth(self.mockSessionManager.didCallEndCurrentSession, timeout: 20)
    //    XCTAssertTrue(sut.childCoordinators.last is LoginCoordinator)
    // }
    //
    // @MainActor
    // func test_evaluateRevisit_requiresNewUserToLogin() throws {
    //    // GIVEN the app has no token information stored
    //    try mockSessionManager.setupSession(returningUser: false, expired: true)
    //    mockSessionManager.errorFromResumeSession = PersistentSessionError.userRemovedLocalAuth
    //    // WHEN the MainCoordinator's evaluateRevisit method is called
    //    sut.evaluateRevisit()
    //    // THEN the session manager should end the current session
    //    waitForTruth(self.mockSessionManager.didCallEndCurrentSession, timeout: 20)
    //    XCTAssertTrue(sut.childCoordinators.last is LoginCoordinator)
    // }
    //
    // @MainActor
    // func test_evaluateRevisit_requiresExpiredUserToLogin() throws {
    //    // GIVEN the app has token information stored but the accessToken is expired
    //    try mockSessionManager.setupSession(expired: true)
    //    mockSessionManager.errorFromResumeSession = TokenError.expired
    //    // WHEN the MainCoordinator's evaluateRevisit method is called
    //    sut.evaluateRevisit()
    //    // THEN the session manager should end the current session
    //    waitForTruth(self.mockSessionManager.didCallEndCurrentSession, timeout: 20)
    //    XCTAssertTrue(sut.childCoordinators.last is LoginCoordinator)
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
    //
    // @MainActor
    // func test_startReauth() throws {
    //    // GIVEN the app has token information store and the accessToken is valid
    //    try mockSessionManager.setupSession(returningUser: true)
    //    // WHEN the MainCoordinator is started
    //    sut.start()
    //    // WHEN the MainCoordinator receives a start reauth notification
    //    NotificationCenter.default
    //        .post(name: Notification.Name(.startReauth), object: nil)
    //    // THEN the tokens should be deleted; the app should be reset
    //    XCTAssertTrue(mockSessionManager.didCallEndCurrentSession)
    // }

}
