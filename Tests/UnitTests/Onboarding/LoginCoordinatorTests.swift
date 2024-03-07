import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class LoginCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockAnalyticsCentre: AnalyticsCentral!
    var mockNetworkMonitor: NetworkMonitoring!
    var mockSecureStore: MockSecureStoreService!
    var mockDefaultStore: MockDefaultsStore!
    var mockUserStore: MockUserStore!
    var tokenHolder: TokenHolder!
    var sut: LoginCoordinator!
    
    override func setUp() {
        super.setUp()
        
        window = .init()
        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCentre = AnalyticsCentre(analyticsService: mockAnalyticsService,
                                              analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockNetworkMonitor = MockNetworkMonitor()
        mockSecureStore = MockSecureStoreService()
        mockDefaultStore = MockDefaultsStore()
        mockUserStore = MockUserStore(secureStoreService: mockSecureStore,
                                      defaultsStore: mockDefaultStore)
        tokenHolder = TokenHolder()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        sut = LoginCoordinator(window: window,
                               root: navigationController,
                               analyticsCentre: mockAnalyticsCentre,
                               secureStoreService: mockSecureStore,
                               defaultStore: mockDefaultStore,
                               tokenHolder: tokenHolder)
    }
    
    override func tearDown() {
        window = nil
        navigationController = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCentre = nil
        mockNetworkMonitor = nil
        mockSecureStore = nil
        mockDefaultStore = nil
        mockUserStore = nil
        tokenHolder = nil
        sut = nil
        
        super.tearDown()
    }
    
    private enum AuthenticationError: Error {
        case generic
    }
    
    private enum SecureStoreError: Error {
        case generic
    }
}

/*
 TESTS
 - LoginCoordinator starts and shows either UnlockScreen or IntroScreen, also testing network error scenario
 - LoginCoordinator triggers launch action for first time VS returning user
 - LoginCoordinator starts launches OnboardingCoordinator
 - LoginCoordinator starts launches AuthenticationCoordinator
 - LoginCoordinator starts launches EnrolmentCoordinator
 */

extension LoginCoordinatorTests {
    func test_start_displaysUnlockScreenViewController() throws {
        mockDefaultStore.returningAuthenticatedUser = true
        // WHEN the LoginCoordinator is started for a returning user
        XCTAssertTrue(sut.root.viewControllers.count == 0)
        sut.start()
        // THEN the visible view controller should be the UnlockScreenViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(navigationController.topViewController is UnlockScreenViewController)
    }
    
    func test_start_displaysIntroViewController() throws {
        // WHEN the LoginCoordinator is started
        XCTAssertTrue(sut.root.viewControllers.count == 0)
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
    }
    
    func test_start_getAccessToken() throws {
        mockDefaultStore.returningAuthenticatedUser = true
        // WHEN the LoginCoordinator is started
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertEqual(tokenHolder.accessToken, "testAccessToken")
    }
    
    func test_start_launchOnboardingCoordinator() throws {
        // WHEN the LoginCoordinator is started
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.childCoordinators[0] is OnboardingCoordinator)
        XCTAssertTrue(sut.root.presentedViewController?.children[0] is ModalInfoViewController)
    }
    
    func test_getAccessToken_succeeds() throws {
        sut.getAccessToken()
        XCTAssertEqual(tokenHolder.accessToken, "testAccessToken")
    }
    
    func test_getAccessToken_errors() throws {
        mockSecureStore.errorFromReadItem = SecureStoreError.generic
        sut.getAccessToken()
        XCTAssertEqual(tokenHolder.accessToken, nil)
    }
    
    func test_launchOnboardingCoordinator_succeeds() throws {
        // WHEN the LoginCoordinator is started
        sut.launchOnboardingCoordinator()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.childCoordinators[0] is OnboardingCoordinator)
        XCTAssertTrue(sut.root.presentedViewController?.children[0] is ModalInfoViewController)
    }
    
    func test_launchOnboardingCoordinator_fails() throws {
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        // WHEN the LoginCoordinator is started
        sut.launchOnboardingCoordinator()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    func test_launchAuthenticationCoordinator() throws {
        // WHEN the LoginCoordinator is started
        sut.launchAuthenticationCoordinator()
        // THEN the LoginCoordinator should have an AuthenticationCoordinator as it's only child coordinator
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is AuthenticationCoordinator)
    }
    
    func test_launchEnrolmentCoordinator_succeeds() throws {
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        let mockLAContext = MockLAContext()
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // WHEN the LoginCoordinator is started
        sut.launchEnrolmentCoordinator(localAuth: mockLAContext)
        // THEN the LoginCoordinator should have an AuthenticationCoordinator as it's only child coordinator
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is EnrolmentCoordinator)
    }
    
    func test_launchEnrolmentCoordinator_fails() throws {
        let mockLAContext = MockLAContext()
        // WHEN the LoginCoordinator is started
        sut.launchEnrolmentCoordinator(localAuth: mockLAContext)
        // THEN the LoginCoordinator should have an AuthenticationCoordinator as it's only child coordinator
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    func test_didRegainFocus_fromAuthenticationCoordinator_withError() throws {
        let authCoordinator = AuthenticationCoordinator(root: navigationController,
                                              session: MockLoginSession(),
                                              analyticsService: mockAnalyticsService,
                                              tokenHolder: tokenHolder)
        authCoordinator.loginError = AuthenticationError.generic
        // GIVEN the LoginCoordinator has started and set it's view controllers
        sut.start()
        // GIVEN the LoginCoordinator regained focus from the AuthenticationCoordinator
        sut.didRegainFocus(fromChild: authCoordinator)
        // THEN the LoginCoordinator should still have IntroViewController as it's top view controller
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
    }
    
    func test_didRegainFocus_fromOnboardingCoordinator() throws {
        let onboardingCoordinator = OnboardingCoordinator(analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        // GIVEN the LoginCoordinator has started and set it's view controllers
        sut.start()
        // GIVEN the LoginCoordinator regained focus from the OnboardingCoordinator
        sut.didRegainFocus(fromChild: onboardingCoordinator)
        // THEN the LoginCoordinator should still have IntroViewController as it's top view controller
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
    }
}
