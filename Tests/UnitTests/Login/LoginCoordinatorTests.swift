import GDSCommon
@testable import OneLogin
import SecureStore
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
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        sut = LoginCoordinator(window: window,
                               root: navigationController,
                               analyticsCentre: mockAnalyticsCentre,
                               networkMonitor: mockNetworkMonitor,
                               secureStoreService: mockSecureStore,
                               defaultStore: mockDefaultStore)
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
        sut = nil
        
        super.tearDown()
    }
    
    private enum AuthenticationError: Error {
        case generic
    }
}

extension LoginCoordinatorTests {
    func test_start_displaysUnlockScreenViewController() throws {
        // GIVEN the LoginCoordinator is started for a returning user
        mockDefaultStore.set(Date() + 60, forKey: .accessTokenExpiry)
        XCTAssertTrue(sut.root.viewControllers.count == 0)
        sut.start()
        // THEN the visible view controller should be the UnlockScreenViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(navigationController.topViewController is UnlockScreenViewController)
    }
    
    func test_start_displaysIntroViewController() throws {
        // GIVEN the LoginCoordinator is started for a returning user with an expired access token
        try mockSecureStore.saveItem(item: "123456789", itemName: .accessToken)
        mockDefaultStore.set(Date() - 60, forKey: .accessTokenExpiry)
        XCTAssertTrue(sut.root.viewControllers.count == 0)
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
        // THEN the secure store should be refreshed and the token info should be removed
        XCTAssertTrue(mockSecureStore.didCallDeleteStore)
        XCTAssertNil(mockDefaultStore.savedData[.accessTokenExpiry])
        XCTAssertNil(mockSecureStore.savedItems[.accessToken])
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
        let introScreen = try XCTUnwrap(navigationController.topViewController as? IntroViewController)
        let introButton: UIButton = try XCTUnwrap(introScreen.view[child: "intro-button"])
        introButton.sendActions(for: .touchUpInside)
        // THEN the displayed screen should be the Network Connection error screen
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 20)
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        let errorScreen = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(errorScreen.viewModel is NetworkConnectionErrorViewModel)
    }
    
    func test_firstTimeUserFlow() throws {
        sut.firstTimeUserFlow()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
        XCTAssertEqual(sut.childCoordinators.count, 1)
    }

    func test_returningUserFlow() throws {
        try mockSecureStore.saveItem(item: "123456789", itemName: .accessToken)
        mockDefaultStore.set(Date() + 60, forKey: .accessTokenExpiry)
        sut.returningUserFlow()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is UnlockScreenViewController)
        XCTAssertEqual(sut.tokenHolder.accessToken, "123456789")
    }
    
    func test_start_getAccessToken_succeeds() throws {
        try mockSecureStore.saveItem(item: "123456789", itemName: .accessToken)
        mockDefaultStore.set(Date() + 60, forKey: .accessTokenExpiry)
        // WHEN the LoginCoordinator is started
        sut.start()
        // THEN the token holder's access token property should get the access token from secure store
        XCTAssertEqual(sut.tokenHolder.accessToken, "123456789")
    }
    
    func test_start_launchOnboardingCoordinator() throws {
        // WHEN the LoginCoordinator is started
        sut.start()
        // THEN the OnboardingCoordinator should be launched
        XCTAssertTrue(sut.childCoordinators[0] is OnboardingCoordinator)
        XCTAssertTrue(sut.root.presentedViewController?.children[0] is ModalInfoViewController)
    }
    
    func test_getAccessToken_succeeds() throws {
        try mockSecureStore.saveItem(item: "123456789", itemName: .accessToken)
        mockDefaultStore.set(Date() + 60, forKey: .accessTokenExpiry)
        // WHEN the LoginCoordinator's getAccessToken method is called
        sut.getAccessToken()
        // THEN the token holder's access token property should get the access token from secure store
        XCTAssertEqual(sut.tokenHolder.accessToken, "123456789")
    }
    
    func test_getAccessToken_errors() throws {
        // GIVEN the secure store returns an error from reading an item
        mockSecureStore.errorFromReadItem = SecureStoreError.unableToRetrieveFromUserDefaults
        // WHEN the LoginCoordinator's getAccessToken method is called
        sut.getAccessToken()
        // THEN the token holder's access token property should not get the access token from secure store
        XCTAssertEqual(sut.tokenHolder.accessToken, nil)
        // THEN login flow should be triggered
        XCTAssertTrue(mockSecureStore.didCallDeleteStore)
        XCTAssertNil(mockDefaultStore.savedData[.accessTokenExpiry])
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
    }
    
    func test_launchOnboardingCoordinator_succeeds() throws {
        // WHEN the LoginCoordinator's launchOnboardingCoordinator method is called
        sut.launchOnboardingCoordinator()
        // THEN the OnboardingCoordinator should be launched
        XCTAssertTrue(sut.childCoordinators[0] is OnboardingCoordinator)
        XCTAssertTrue(sut.root.presentedViewController?.children[0] is ModalInfoViewController)
    }
    
    func test_launchOnboardingCoordinator_fails() throws {
        // GIVEN the user has accepted analytics permissions
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        // WHEN the LoginCoordinator's launchOnboardingCoordinator method is called
        sut.launchOnboardingCoordinator()
        // THEN the OnboardingCoordinator should not be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    func test_launchAuthenticationCoordinator() throws {
        // WHEN the LoginCoordinator's launchAuthenticationCoordinator method is called
        sut.launchAuthenticationCoordinator()
        // THEN the LoginCoordinator should have an AuthenticationCoordinator as it's only child coordinator
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is AuthenticationCoordinator)
    }
    
    func test_launchEnrolmentCoordinator_succeeds() throws {
        // GIVEN the token holder's token response has tokens
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // GIVEN the local authentication context returned true for returnedFromCanEvaluatePolicyForBiometrics
        let mockLAContext = MockLAContext()
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // WHEN the LoginCoordinator's launchEnrolmentCoordinator method is called with the local authentication context
        sut.launchEnrolmentCoordinator(localAuth: mockLAContext)
        // THEN the LoginCoordinator should have an EnrolmentCoordinator as it's only child coordinator
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is EnrolmentCoordinator)
    }
    
    func test_launchEnrolmentCoordinator_fails() throws {
        // GIVEN the local authentication context returned false for returnedFromCanEvaluatePolicyForBiometrics
        let mockLAContext = MockLAContext()
        // WHEN the LoginCoordinator is started
        sut.launchEnrolmentCoordinator(localAuth: mockLAContext)
        // THEN the LoginCoordinator should not have an EnrolmentCoordinator as it's only child coordinator
        XCTAssertEqual(sut.childCoordinators.count, 1)
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
    
    func test_didRegainFocus_fromAuthenticationCoordinator_withError() throws {
        let authCoordinator = AuthenticationCoordinator(root: navigationController,
                                                        session: MockLoginSession(),
                                                        analyticsService: mockAnalyticsService,
                                                        tokenHolder: TokenHolder())
        authCoordinator.loginError = AuthenticationError.generic
        // GIVEN the LoginCoordinator has started and set it's view controllers
        sut.start()
        // GIVEN the LoginCoordinator regained focus from the AuthenticationCoordinator
        sut.didRegainFocus(fromChild: authCoordinator)
        // THEN the LoginCoordinator should still have IntroViewController as it's top view controller
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
    }
}
