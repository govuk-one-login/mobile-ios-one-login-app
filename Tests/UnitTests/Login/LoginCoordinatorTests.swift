import GDSCommon
@testable import OneLogin
import SecureStore
import XCTest

@MainActor
final class LoginCoordinatorTests: XCTestCase {
    var mockWindowManager: MockWindowManager!
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockAnalyticsCenter: AnalyticsCentral!
    var mockNetworkMonitor: NetworkMonitoring!
    var mockSecureStore: MockSecureStoreService!
    var mockOpenSecureStore: MockSecureStoreService!
    var mockDefaultStore: MockDefaultsStore!
    var mockUserStore: UserStorage!
    var mockTokenHolder: TokenHolder!
    var mockTokenVerifier: MockTokenVerifier!
    var sut: LoginCoordinator!
    
    override func setUp() {
        super.setUp()
        
        mockWindowManager = MockWindowManager(appWindow: UIWindow())
        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = AnalyticsCenter(analyticsService: mockAnalyticsService,
                                              analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockNetworkMonitor = MockNetworkMonitor()
        mockSecureStore = MockSecureStoreService()
        mockOpenSecureStore = MockSecureStoreService()
        mockDefaultStore = MockDefaultsStore()
        mockUserStore = UserStorage(secureStoreService: mockSecureStore,
                                    openSecureStoreService: mockOpenSecureStore,
                                    defaultsStore: mockDefaultStore)
        mockTokenHolder = TokenHolder()
        mockTokenVerifier = MockTokenVerifier()
        mockWindowManager.appWindow.rootViewController = navigationController
        mockWindowManager.appWindow.makeKeyAndVisible()
        sut = LoginCoordinator(windowManager: mockWindowManager,
                               root: navigationController,
                               analyticsCenter: mockAnalyticsCenter,
                               userStore: mockUserStore,
                               networkMonitor: mockNetworkMonitor,
                               tokenHolder: mockTokenHolder,
                               tokenVerifier: mockTokenVerifier)
    }
    
    override func tearDown() {
        mockWindowManager = nil
        navigationController = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCenter = nil
        mockNetworkMonitor = nil
        mockSecureStore = nil
        mockOpenSecureStore = nil
        mockDefaultStore = nil
        mockUserStore = nil
        mockTokenHolder = nil
        sut = nil
        
        super.tearDown()
    }
    
    private enum AuthenticationError: Error {
        case generic
    }
}

extension LoginCoordinatorTests {
    func test_start() {
        // WHEN the LoginCoordinator's start method is called
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
    }
    
    func test_introViewController_networkError() throws {
        // GIVEN the network is not connected
        mockNetworkMonitor.isConnected = false
        // WHEN the LoginCoordinator is started for a first time user
        XCTAssertTrue(sut.root.viewControllers.count == 0)
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
        // WHEN the button to login is tapped
        let introScreen = try XCTUnwrap(sut.root.topViewController as? IntroViewController)
        let introButton: UIButton = try XCTUnwrap(introScreen.view[child: "intro-button"])
        introButton.sendActions(for: .touchUpInside)
        // THEN the displayed screen should be the Network Connection error screen
        waitForTruth(self.sut.root.viewControllers.count == 2, timeout: 20)
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let errorScreen = try XCTUnwrap(sut.root.topViewController as? GDSErrorViewController)
        XCTAssertTrue(errorScreen.viewModel is NetworkConnectionErrorViewModel)
        let errorButton: UIButton = try XCTUnwrap(errorScreen.view[child: "error-primary-button"])
        errorButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(introButton.isEnabled)
    }
    
    func test_start_launchOnboardingCoordinator() {
        // WHEN the LoginCoordinator is started
        sut.start()
        // THEN the OnboardingCoordinator should be launched
        XCTAssertTrue(sut.childCoordinators[0] is OnboardingCoordinator)
        XCTAssertTrue(sut.root.presentedViewController?.children[0] is ModalInfoViewController)
    }
    
    func test_start_skips_launchOnboardingCoordinator() {
        // GIVEN the user has accepted analytics permissions
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        // WHEN the LoginCoordinator's start method is called
        sut.start()
        // THEN the OnboardingCoordinator should not be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    func test_launchAuthenticationCoordinator() {
        // WHEN the LoginCoordinator's launchAuthenticationCoordinator method is called
        sut.launchAuthenticationCoordinator()
        // THEN the LoginCoordinator should have an AuthenticationCoordinator as it's only child coordinator
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is AuthenticationCoordinator)
    }
    
    func test_handleUniversalLink() {
        // WHEN the handleUniversalLink method is called
        // This test is purely to get test coverage atm as we will not be able to test for effects on unmocked subcoordinators
        sut.handleUniversalLink(URL(string: "google.com")!)
    }
    
    func test_launchEnrolmentCoordinator() {
        // GIVEN sufficient test set up to ensure enrolment coordinator does not finish before test assertions
        let mockLAContext = MockLAContext()
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // WHEN the LoginCoordinator's launchEnrolmentCoordinator method is called with the local authentication context
        sut.launchEnrolmentCoordinator(localAuth: mockLAContext)
        // THEN the LoginCoordinator should have an EnrolmentCoordinator as it's only child coordinator
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is EnrolmentCoordinator)
    }
    
    func test_didRegainFocus_fromOnboardingCoordinator() {
        let mockURLOpener = MockURLOpener()
        let onboardingCoordinator = OnboardingCoordinator(analyticsPreferenceStore: mockAnalyticsPreferenceStore,
                                                          urlOpener: mockURLOpener)
        // GIVEN the LoginCoordinator has started and set it's view controllers
        sut.start()
        // GIVEN the LoginCoordinator regained focus from the OnboardingCoordinator
        sut.didRegainFocus(fromChild: onboardingCoordinator)
        // THEN the LoginCoordinator should still have IntroViewController as it's top view controller
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
    }
    
    func test_didRegainFocus_fromAuthenticationCoordinator_withError() throws {
        let authCoordinator = AuthenticationCoordinator(root: navigationController,
                                                        analyticsService: mockAnalyticsService,
                                                        userStore: mockUserStore,
                                                        session: MockLoginSession(),
                                                        tokenHolder: mockTokenHolder)
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
