// swiftlint:disable file_length
import Authentication
import GDSCommon
@testable import OneLogin
import SecureStore
import XCTest

final class LoginCoordinatorTests: XCTestCase {
    var appWindow: UIWindow!
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockSessionManager: MockSessionManager!
    var mockNetworkMonitor: NetworkMonitoring!
    var mockAuthenticationService: MockAuthenticationService!
    var sut: LoginCoordinator!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        appWindow = .init()
        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockSessionManager = MockSessionManager()
        mockNetworkMonitor = MockNetworkMonitor()
        mockAuthenticationService = MockAuthenticationService(sessionManager: mockSessionManager)
        appWindow.rootViewController = navigationController
        appWindow.makeKeyAndVisible()
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsService: mockAnalyticsService,
                               analyticsPreferenceStore: mockAnalyticsPreferenceStore,
                               sessionManager: mockSessionManager,
                               networkMonitor: mockNetworkMonitor,
                               authService: mockAuthenticationService,
                               isExpiredUser: false)
    }
    
    override func tearDown() {
        appWindow = nil
        navigationController = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockSessionManager = nil
        mockNetworkMonitor = nil
        sut = nil
        
        super.tearDown()
    }
    
    @MainActor
    func reauthLogin() {
        mockSessionManager.isReturningUser = true
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsService: mockAnalyticsService,
                               analyticsPreferenceStore: mockAnalyticsPreferenceStore,
                               sessionManager: mockSessionManager,
                               networkMonitor: mockNetworkMonitor,
                               authService: mockAuthenticationService,
                               isExpiredUser: true)
    }
}

enum AuthenticationError: Error {
    case generic
}

extension LoginCoordinatorTests {
    // MARK: Login
    @MainActor
    func test_start() {
        // WHEN the LoginCoordinator is started
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
    }
    
    @MainActor
    func test_start_reauth() throws {
        // WHEN the LoginCoordinator is started in a reauth flow
        reauthLogin()
        sut.start()
        // THEN the user sees the session expired screen
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        // THEN the visible view controller should be the GDSInformationViewController
        let screen = try XCTUnwrap(sut.root.topViewController as? GDSInformationViewController)
        // THEN the visible view controller's view model should be the SignOutWarningViewModel
        XCTAssertTrue(screen.viewModel is SignOutWarningViewModel)
    }
    
    @MainActor
    func test_authenticate_launchAuthenticationService() {
        // WHEN the LoginCoordinator's authenticate method is called
        sut.authenticate()
        // THEN the AuthenticationService should be launched
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
    }
    
    @MainActor
    func test_authenticate_noNetwork() throws {
        // GIVEN the network is not connected
        mockNetworkMonitor.isConnected = false
        // WHEN the LoginCoordinator's authenticate method is called
        sut.authenticate()
        // THEN the visible view controller should be the GDSErrorScreen
        let errorScreen = try XCTUnwrap(sut.root.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the NetworkConnectionErrorViewModel
        XCTAssertTrue(errorScreen.viewModel is NetworkConnectionErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService() {
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        // THEN the AuthenticationService should be launched
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
    }
    
    @MainActor
    func test_launchAuthenticationService_sessionMismatch() throws {
        // GIVEN the authentication session returns a sessionMismatch error
        mockSessionManager.errorFromStartSession = PersistentSessionError.sessionMismatch
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the DataDeletedWarningViewModel
        XCTAssertTrue(vc.viewModel is DataDeletedWarningViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_cannotDeleteData() throws {
        // GIVEN the authentication session returns a cannotDeleteData error
        mockSessionManager.errorFromStartSession = PersistentSessionError.cannotDeleteData(MockWalletError.cantDelete)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnableToLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is RecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_accessDenied() throws {
        // GIVEN the authentication session returns an access denied error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .authorizationAccessDenied)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the DataDeletedWarningViewModel
        XCTAssertTrue(vc.viewModel is DataDeletedWarningViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_network() throws {
        // GIVEN the authentication session returns a network error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .network)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the NetworkConnectionErrorViewModel
        XCTAssertTrue(vc.viewModel is NetworkConnectionErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_authInvalidRequest() throws {
        // GIVEN the authentication session returns a invalidRequest error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .authorizationInvalidRequest)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_authUnauthorizedClient() throws {
        // GIVEN the authentication session returns a invalidRequest error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .authorizationUnauthorizedClient)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_unsupportedResponse() throws {
        // GIVEN the authentication session returns a invalidRequest error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .authorizationUnsupportedResponseType)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_authInvalidScope() throws {
        // GIVEN the authentication session returns a invalidRequest error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .authorizationInvalidScope)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_temporarilyUnavailable() throws {
        // GIVEN the authentication session returns a invalidRequest error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .authorizationTemporarilyUnavailable)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_tokenInvalidRequest() throws {
        // GIVEN the authentication session returns a invalidRequest error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .tokenInvalidRequest)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_tokenUnauthorizedClient() throws {
        // GIVEN the authentication session returns a invalidRequest error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .tokenUnauthorizedClient)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_tokenInvalidScope() throws {
        // GIVEN the authentication session returns a invalidRequest error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .tokenInvalidScope)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_invalidClient() throws {
        // GIVEN the authentication session returns a invalidRequest error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .tokenInvalidClient)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_invalidGrant() throws {
        // GIVEN the authentication session returns a invalidRequest error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .tokenInvalidGrant)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_unsupportedGrant() throws {
        // GIVEN the authentication session returns a invalidRequest error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .tokenUnsupportedGrantType)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_clientError() throws {
        // GIVEN the authentication session returns a invalidRequest error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .tokenClientError)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnrecoverableLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is UnrecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_authServerError() throws {
        // GIVEN the authentication session returns a invalidRequest error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .authorizationServerError)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the RecoverableLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is RecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_authUnknownError() throws {
        // GIVEN the authentication session returns a invalidRequest error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .authorizationUnknownError)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the RecoverableLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is RecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_tokenUnknownError() throws {
        // GIVEN the authentication session returns a clientError error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .tokenUnknownError)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnableToLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is RecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_serverError() throws {
        // GIVEN the authentication session returns a serverError error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .generalServerError)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnableToLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is RecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_safariError() throws {
        // GIVEN the authentication session returns a serverError error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .safariOpenError)
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnableToLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is RecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_jwtFetchError() throws {
        // GIVEN the authentication session returns a unableToFetchJWKs error
        mockSessionManager.errorFromStartSession = JWTVerifierError.unableToFetchJWKs
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnableToLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is RecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_jwtVerifyError() throws {
        // GIVEN the authentication session returns a invalidJWTFormat error
        mockSessionManager.errorFromStartSession = JWTVerifierError.invalidJWTFormat
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the UnableToLoginErrorViewModel
        XCTAssertTrue(vc.viewModel is RecoverableLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_generic() throws {
        // GIVEN the authentication session returns a generic error
        mockSessionManager.errorFromStartSession = LoginErrorV2(reason: .generic(description: ""))
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the GenericErrorViewModel
        XCTAssertTrue(vc.viewModel is GenericErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_catchAllError() throws {
        // GIVEN the authentication session returns a generic error
        mockSessionManager.errorFromStartSession = AuthenticationError.generic
        // WHEN the LoginCoordinator's launchAuthenticationService method is called
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the GenericErrorViewModel
        XCTAssertTrue(vc.viewModel is GenericErrorViewModel)
    }
    
    @MainActor
    func test_handleUniversalLink_catchAllError() throws {
        // GIVEN the authentication session returns a generic error
        let callbackURL = try XCTUnwrap(URL(string: "https://www.test.com"))
        // WHEN the LoginCoordinator's handleUniversalLink method is called
        sut.handleUniversalLink(callbackURL)
        // THEN the visible view controller should be the GDSErrorScreen
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorScreen)
        // THEN the visible view controller's view model should be the GenericErrorViewModel
        XCTAssertTrue(vc.viewModel is GenericErrorViewModel)
    }
    
    // MARK: Coordinator flow
    @MainActor
    func test_launchOnboardingCoordinator() {
        sut.start()
        // WHEN the launchOnboardingCoordinator method is called
        sut.launchOnboardingCoordinator()
        // THEN the OnboardingCoordinator should be launched
        XCTAssertTrue(sut.childCoordinators[0] is OnboardingCoordinator)
        XCTAssertTrue(sut.root.presentedViewController?.children[0] is ModalInfoViewController)
    }
    
    @MainActor
    func test_skip_launchOnboardingCoordinator() {
        sut.start()
        // GIVEN the user has accepted analytics permissions
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        // WHEN the launchOnboardingCoordinator method is called
        sut.launchOnboardingCoordinator()
        // THEN the OnboardingCoordinator should not be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    @MainActor
    func test_launchEnrolmentCoordinator() {
        // WHEN the LoginCoordinator's launchEnrolmentCoordinator method is called with the local authentication context
        sut.launchEnrolmentCoordinator()
        // THEN the LoginCoordinator should have an EnrolmentCoordinator as it's only child coordinator
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is EnrolmentCoordinator)
    }
 }
// swiftlint:enable file_length
