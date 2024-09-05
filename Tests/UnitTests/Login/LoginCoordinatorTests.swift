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
        appWindow.rootViewController = navigationController
        appWindow.makeKeyAndVisible()
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsCenter: mockAnalyticsCenter,
                               sessionManager: mockSessionManager,
                               networkMonitor: mockNetworkMonitor,
                               loginError: nil)
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
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsCenter: mockAnalyticsCenter,
                               sessionManager: mockSessionManager,
                               networkMonitor: mockNetworkMonitor,
                               loginError: TokenError.expired)
        mockSessionManager.isReturningUser = true
    }
    
    @MainActor
    func errorLogin() {
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsCenter: mockAnalyticsCenter,
                               sessionManager: mockSessionManager,
                               networkMonitor: mockNetworkMonitor,
                               loginError: JWTVerifierError.invalidJWTFormat)
    }
    
    @MainActor
    func checkLocalAuth() {
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsCenter: mockAnalyticsCenter,
                               sessionManager: mockSessionManager,
                               networkMonitor: mockNetworkMonitor,
                               loginError: LocalAuthenticationError.noBiometricsOrPasscode)
    }
    
    private enum AuthenticationError: Error {
        case generic
    }
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
        // THEN the OnboardingCoordinator should be launched
        XCTAssertTrue(sut.childCoordinators[0] is OnboardingCoordinator)
        XCTAssertTrue(sut.root.presentedViewController?.children[0] is ModalInfoViewController)
    }
    
    @MainActor
    func test_start_reauth() throws {
        // WHEN the LoginCoordinator is started in a reauth flow
        reauthLogin()
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
        // THEN the presented view controller should be the GDSErrorViewController
        let warningScreen = try XCTUnwrap(sut.root.presentedViewController as? GDSErrorViewController)
        // THEN the presented view model should be the SignOutWarningViewModel
        XCTAssertTrue(warningScreen.viewModelV2 is SignOutWarningViewModel)
    }
    
    @MainActor
    func test_start_withNoBiometricsOrPasscode() throws {
        checkLocalAuth()
        sut.start()
        
        let warningScreen = try XCTUnwrap(sut.root.presentedViewController as? GDSErrorViewController)
        // THEN the presented view model should be the SignOutWarningViewModel
        XCTAssertTrue(warningScreen.viewModelV2 is SignOutWarningViewModel)
    }
    
    @MainActor
    func test_start_error() throws {
        // WHEN the LoginCoordinator is started in an error flow
        errorLogin()
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
        // THEN the presented view controller should be the GDSErrorViewController
        let warningScreen = try XCTUnwrap(sut.root.presentedViewController as? GDSErrorViewController)
        // THEN the presented view model should be the UnableToLoginErrorViewModel
        XCTAssertTrue(warningScreen.viewModel is UnableToLoginErrorViewModel)
    }
    
    @MainActor
    func test_authenticate_missingPersistenId() throws {
        mockSessionManager.isReturningUser = true
        mockSessionManager.isPersistentSessionIDMissing = true

        let exp = XCTNSNotificationExpectation(name: Notification.Name(.clearWallet),
                                               object: nil,
                                               notificationCenter: NotificationCenter.default)
        // WHEN the LoginCoordinator is started and the persistent session id is missing
        sut.authenticate()
        // THEN the clear wallet notification should be posted
        wait(for: [exp], timeout: 20)
    }
    
    @MainActor
    func test_authenticate_opensAuthenticationCoordinator() throws {
        // WHEN the LoginCoordinator is started
        sut.authenticate()
        // THEN the AuthenticationCoordinator should be launched
        XCTAssertTrue(sut.childCoordinators.last is AuthenticationCoordinator)
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
        let errorButton: UIButton = try XCTUnwrap(errorScreen.view[child: "error-primary-button"])
        // WHEN the network error screens button is pressed
        mockNetworkMonitor.isConnected = true
        errorButton.sendActions(for: .touchUpInside)
        // THEN the AuthenticationCoordinator is launched
        XCTAssertTrue(sut.childCoordinators.last is AuthenticationCoordinator)
    }
    
    // MARK: Coordinator flow
    @MainActor
    func test_start_skips_launchOnboardingCoordinator() {
        // GIVEN the user has accepted analytics permissions
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        // WHEN the LoginCoordinator's start method is called
        sut.start()
        // THEN the OnboardingCoordinator should not be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }

    @MainActor
    func test_launchAuthenticationCoordinator() {
        // WHEN the LoginCoordinator's launchAuthenticationCoordinator method is called
        sut.launchAuthenticationCoordinator()
        // THEN the LoginCoordinator should have an AuthenticationCoordinator as it's only child coordinator
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is AuthenticationCoordinator)
    }
    
    @MainActor
    func test_handleUniversalLink() {
        // WHEN the handleUniversalLink method is called
        // This test is purely to get test coverage atm as we will not be able to test for effects on unmocked subcoordinators
        sut.handleUniversalLink(URL(string: "google.com")!)
    }
    
    @MainActor
    func test_launchEnrolmentCoordinator() {
        // GIVEN sufficient test set up to ensure enrolment coordinator does not finish before test assertions
        let mockLocalAuthManager = MockLocalAuthManager()
        mockLocalAuthManager.LABiometricsIsEnabledOnTheDevice = true
        // WHEN the LoginCoordinator's launchEnrolmentCoordinator method is called with the local authentication context
        sut.launchEnrolmentCoordinator()
        // THEN the LoginCoordinator should have an EnrolmentCoordinator as it's only child coordinator
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is EnrolmentCoordinator)
    }
    
    @MainActor
    func test_didRegainFocus_fromOnboardingCoordinator() {
        let onboardingCoordinator = OnboardingCoordinator(analyticsPreferenceStore: mockAnalyticsPreferenceStore,
                                                          urlOpener: MockURLOpener())
        // GIVEN the LoginCoordinator has started and set it's view controllers
        sut.start()
        // GIVEN the LoginCoordinator regained focus from the OnboardingCoordinator
        sut.didRegainFocus(fromChild: onboardingCoordinator)
        // THEN the LoginCoordinator should still have IntroViewController as it's top view controller
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
    }
    
    @MainActor
    func test_didRegainFocus_fromAuthenticationCoordinator_withError() throws {
        let authCoordinator = AuthenticationCoordinator(window: appWindow,
                                                        root: navigationController,
                                                        analyticsService: mockAnalyticsService,
                                                        sessionManager: mockSessionManager,
                                                        session: MockLoginSession(window: UIWindow()))
        authCoordinator.authError = AuthenticationError.generic
        // GIVEN the LoginCoordinator has started and set it's view controllers
        sut.start()
        let vc = try XCTUnwrap(sut.root.topViewController as? IntroViewController)
        vc.loadView()
        // GIVEN the LoginCoordinator regained focus from the AuthenticationCoordinator
        sut.didRegainFocus(fromChild: authCoordinator)
        // THEN the LoginCoordinator should still have IntroViewController as it's top view controller
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
        let introButton: UIButton = try XCTUnwrap(vc.view[child: "intro-button"])
        XCTAssertTrue(introButton.isEnabled)
    }
}
