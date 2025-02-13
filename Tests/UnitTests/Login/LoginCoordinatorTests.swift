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
    var mockAnalyticsCenter: AnalyticsCentral!
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
        mockAnalyticsCenter = AnalyticsCenter(analyticsService: mockAnalyticsService,
                                              analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockSessionManager = MockSessionManager()
        mockNetworkMonitor = MockNetworkMonitor()
        mockAuthenticationService = MockAuthenticationService(sessionManager: mockSessionManager)
        appWindow.rootViewController = navigationController
        appWindow.makeKeyAndVisible()
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsCenter: mockAnalyticsCenter,
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
        mockAnalyticsCenter = nil
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
                               analyticsCenter: mockAnalyticsCenter,
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

        let screen = try XCTUnwrap(sut.root.topViewController as? GDSErrorViewController)
        XCTAssertTrue(screen.viewModelV2 is SignOutWarningViewModel)
    }
    
    @MainActor
    func test_authenticate_launchAuthenticationService() {
        // WHEN the LoginCoordinator is started
        sut.authenticate()
        // THEN the AuthenticationCoordinator should be launched
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
    }
    
    @MainActor
    func test_authenticate_noNetwork() throws {
        // GIVEN the network is not connected
        mockNetworkMonitor.isConnected = false
        // WHEN the LoginCoordinator's authenticate method is called for a first time user
        sut.authenticate()
        // THEN the visible view controller should be the IntroViewController
        let errorScreen = try XCTUnwrap(sut.root.topViewController as? GDSErrorViewController)
        XCTAssertTrue(errorScreen.viewModel is NetworkConnectionErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService() {
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
    }
    
    @MainActor
    func test_launchAuthenticationService_sessionMismatch() throws {
        mockSessionManager.errorFromStartSession = PersistentSessionError.sessionMismatch
        sut.launchAuthenticationService()
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is DataDeletedWarningViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_cannotDeleteData() throws {
        mockSessionManager.errorFromStartSession = PersistentSessionError.cannotDeleteData(MockWalletError.cantDelete)
        sut.launchAuthenticationService()
        // WHEN the AuthenticationCoordinator is started
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a network error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'network' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_network() throws {
        mockSessionManager.errorFromStartSession = LoginError.network
        sut.launchAuthenticationService()
        // WHEN the AuthenticationCoordinator is started
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a network error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'network' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is NetworkConnectionErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_non200() throws {
        mockSessionManager.errorFromStartSession = LoginError.non200
        sut.launchAuthenticationService()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a non200 error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'unable to login' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_invalidRequest() throws {
        mockSessionManager.errorFromStartSession = LoginError.invalidRequest
        sut.launchAuthenticationService()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a non200 error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'unable to login' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_clientError() throws {
        mockSessionManager.errorFromStartSession = LoginError.clientError
        sut.launchAuthenticationService()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a non200 error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'unable to login' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_serverError() throws {
        mockSessionManager.errorFromStartSession = LoginError.serverError
        sut.launchAuthenticationService()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a server error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'unable to login' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_jwtFetchError() throws {
        mockSessionManager.errorFromStartSession = JWTVerifierError.unableToFetchJWKs
        sut.launchAuthenticationService()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and the subsequent call to the JWKS service fails
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the login error screen is shown
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_jwtVerifyError() throws {
        mockSessionManager.errorFromStartSession = JWTVerifierError.invalidJWTFormat
        sut.launchAuthenticationService()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and the subsequent call to the JWKS service fails
        waitForTruth(self.mockSessionManager.didCallStartSession, timeout: 20)
        // THEN the login error screen is shown
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is UnableToLoginErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_generic() throws {
        mockSessionManager.errorFromStartSession = LoginError.generic(description: "")
        sut.launchAuthenticationService()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is a generic error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'generic' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is GenericErrorViewModel)
    }
    
    @MainActor
    func test_launchAuthenticationService_catchAllError() throws {
        mockSessionManager.errorFromStartSession = AuthenticationError.generic
        sut.launchAuthenticationService()
        // GIVEN the AuthenticationCoordinator has logged in via start()
        // WHEN the AuthenticationCoordinator calls performLoginFlow on the session
        // and there is an unknown error
        waitForTruth(self.navigationController.viewControllers.count == 1, timeout: 20)
        // THEN the 'generic' error screen is shown
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is GenericErrorViewModel)
    }
    
    @MainActor
    func test_handleUniversalLink_catchAllError() throws {
        // WHEN the AuthenticationCoordinator calls finalise on the session
        // and there is an unknown error
        let callbackURL = try XCTUnwrap(URL(string: "https://www.test.com"))
        sut.handleUniversalLink(callbackURL)
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 20)
        // THEN the loading screen is on the navigation stack
        XCTAssertTrue(navigationController.viewControllers.first is GDSLoadingViewController)
        // THEN the 'generic' error screen is top of the navigation stack
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
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
