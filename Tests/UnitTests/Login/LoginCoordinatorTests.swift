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
    var mockDefaultStore: MockDefaultsStore!
    var mockUserStore: UserStorage!
    var mockURLOpener: URLOpener!
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
        mockDefaultStore = MockDefaultsStore()
        mockUserStore = UserStorage(secureStoreService: mockSecureStore,
                                    defaultsStore: mockDefaultStore)
        mockWindowManager.appWindow.rootViewController = navigationController
        mockWindowManager.appWindow.makeKeyAndVisible()
        mockURLOpener = MockURLOpener()
        sut = LoginCoordinator(windowManager: mockWindowManager,
                               root: navigationController,
                               analyticsCenter: mockAnalyticsCenter,
                               networkMonitor: mockNetworkMonitor,
                               userStore: mockUserStore,
                               tokenHolder: TokenHolder())
    }
    
    override func tearDown() {
        mockWindowManager = nil
        navigationController = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCenter = nil
        mockNetworkMonitor = nil
        mockSecureStore = nil
        mockDefaultStore = nil
        mockUserStore = nil
        mockURLOpener = nil
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
        XCTAssertTrue(mockWindowManager.displayUnlockWindowCalled)
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
    
    func test_firstTimeUserFlow() throws {
        // WHEN the LoginCoordinator's firstTimeUserFlow method is called
        sut.firstTimeUserFlow()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
        XCTAssertEqual(sut.childCoordinators.count, 1)
    }
    
    func test_returningUserFlow() throws {
        // GIVEN the id token is saved in secure store
        try mockSecureStore.saveItem(item: MockJWKSResponse.idToken, itemName: .idToken)
        // WHEN the LoginCoordinator's returningUserFlow method is called
        sut.returningUserFlow()
        // THEN the token holder's access idTokenPayload should be populated
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled == true, timeout: 20)
        XCTAssertNotNil(sut.tokenHolder.idTokenPayload)
    }
    
    func test_start_getAccessToken_succeeds() throws {
        // GIVEN the access token is saved in secure store and the token expiry is in date
        try mockSecureStore.saveItem(item: MockJWKSResponse.idToken, itemName: .idToken)
        mockDefaultStore.set(Date() + 60, forKey: .accessTokenExpiry)
        // WHEN the LoginCoordinator is started
        sut.start()
        // THEN the token holder's idTokenPayload should be populated
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled == true, timeout: 20)
        XCTAssertNotNil(sut.tokenHolder.idTokenPayload)
    }
    
    func test_start_launchOnboardingCoordinator() throws {
        // WHEN the LoginCoordinator is started
        sut.start()
        // THEN the OnboardingCoordinator should be launched
        XCTAssertTrue(sut.childCoordinators[0] is OnboardingCoordinator)
        XCTAssertTrue(sut.root.presentedViewController?.children[0] is ModalInfoViewController)
    }
    
    func test_getAccessToken_succeeds() throws {
        try mockSecureStore.saveItem(item: MockJWKSResponse.idToken, itemName: .idToken)
        mockDefaultStore.set(Date() + 60, forKey: .accessTokenExpiry)
        // WHEN the LoginCoordinator's getAccessToken method is called
        sut.getIdToken()
        // THEN the token holder's access token property should get the access token from secure store
        waitForTruth(self.mockWindowManager.hideUnlockWindowCalled == true, timeout: 20)
        XCTAssertNotNil(sut.tokenHolder.idTokenPayload)
    }
    
    func test_getAccessToken_error_unableToRetrieveFromUserDefaults() throws {
        // GIVEN the secure store returns a unableToRetrieveFromUserDefaults error from trying to read the access token
        mockSecureStore.errorFromReadItem = SecureStoreError.unableToRetrieveFromUserDefaults
        // WHEN the LoginCoordinator's getAccessToken method is called
        sut.getIdToken()
        // THEN the token holder's access token property should not get the access token from secure store
        waitForTruth(self.sut.tokenHolder.accessToken == nil, timeout: 20)
        // THEN user store should be refreshed
        XCTAssertTrue(mockSecureStore.didCallDeleteStore)
        XCTAssertNil(mockDefaultStore.savedData[.accessTokenExpiry])
        XCTAssertTrue(mockWindowManager.hideUnlockWindowCalled)
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
    }
    
    func test_getAccessToken_error_cantInitialiseData() throws {
        // GIVEN the secure store returns a cantInitialiseData error from trying to read the access token
        mockSecureStore.errorFromReadItem = SecureStoreError.cantInitialiseData
        // WHEN the LoginCoordinator's getAccessToken method is called
        sut.getIdToken()
        // THEN the token holder's access token property should not get the access token from secure store
        waitForTruth(self.sut.tokenHolder.accessToken == nil, timeout: 20)
        // THEN user store should be refreshed
        XCTAssertTrue(mockSecureStore.didCallDeleteStore)
        XCTAssertNil(mockDefaultStore.savedData[.accessTokenExpiry])
        XCTAssertTrue(mockWindowManager.hideUnlockWindowCalled)
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
    }
    
    func test_getAccessToken_error_cantRetrieveKey() throws {
        // GIVEN the secure store returns a cantRetrieveKey error from trying to read the access token
        mockSecureStore.errorFromReadItem = SecureStoreError.cantRetrieveKey
        // WHEN the LoginCoordinator's getAccessToken method is called
        sut.getIdToken()
        // THEN the token holder's access token property should not get the access token from secure store
        waitForTruth(self.sut.tokenHolder.accessToken == nil, timeout: 20)
        // THEN user store should be refreshed
        XCTAssertTrue(mockSecureStore.didCallDeleteStore)
        XCTAssertNil(mockDefaultStore.savedData[.accessTokenExpiry])
        XCTAssertTrue(mockWindowManager.hideUnlockWindowCalled)
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
    
    func test_launchOnboardingCoordinator_skips() throws {
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
    
    func test_launchEnrolmentCoordinator() throws {
        // GIVEN sufficient test set up to ensure EnrolmentCoordinator does not finish before test assertions
        let mockLAContext = MockLAContext()
        mockLAContext.returnedFromCanEvaluatePolicyForBiometrics = true
        // WHEN the LoginCoordinator's launchEnrolmentCoordinator method is called with the local authentication context
        sut.launchEnrolmentCoordinator(localAuth: mockLAContext)
        // THEN the LoginCoordinator should have an EnrolmentCoordinator as it's only child coordinator
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators[0] is EnrolmentCoordinator)
    }
    
    func test_didRegainFocus_fromOnboardingCoordinator() throws {
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
                                                        session: MockLoginSession(),
                                                        analyticsService: mockAnalyticsService,
                                                        tokenHolder: TokenHolder())
        authCoordinator.loginError = AuthenticationError.generic
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
