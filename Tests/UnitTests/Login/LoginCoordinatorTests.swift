import GDSCommon
@testable import OneLogin
import SecureStore
import XCTest

@MainActor
final class LoginCoordinatorTests: XCTestCase {
    var appWindow: UIWindow!
    var navigationController: UINavigationController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockAnalyticsCenter: AnalyticsCentral!
    var mockSecureStore: MockSecureStoreService!
    var mockOpenSecureStore: MockSecureStoreService!
    var mockDefaultStore: MockDefaultsStore!
    var mockUserStore: UserStorage!
    var mockNetworkMonitor: NetworkMonitoring!
    var sut: LoginCoordinator!
    
    override func setUp() {
        super.setUp()
        
        appWindow = .init()
        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = AnalyticsCenter(analyticsService: mockAnalyticsService,
                                              analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockSecureStore = MockSecureStoreService()
        mockOpenSecureStore = MockSecureStoreService()
        mockDefaultStore = MockDefaultsStore()
        mockUserStore = UserStorage(authenticatedStore: mockSecureStore,
                                    openStore: mockOpenSecureStore,
                                    defaultsStore: mockDefaultStore)
        mockNetworkMonitor = MockNetworkMonitor()
        appWindow.rootViewController = navigationController
        appWindow.makeKeyAndVisible()
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsCenter: mockAnalyticsCenter,
                               userStore: mockUserStore,
                               networkMonitor: mockNetworkMonitor,
                               loginError: nil)
    }
    
    override func tearDown() {
        appWindow = nil
        navigationController = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCenter = nil
        mockSecureStore = nil
        mockOpenSecureStore = nil
        mockDefaultStore = nil
        mockUserStore = nil
        mockNetworkMonitor = nil
        sut = nil
        
        super.tearDown()
    }
    
    func reauthLogin() {
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsCenter: mockAnalyticsCenter,
                               userStore: mockUserStore,
                               networkMonitor: mockNetworkMonitor,
                               loginError: TokenError.expired)
    }
    
    func errorLogin() {
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsCenter: mockAnalyticsCenter,
                               userStore: mockUserStore,
                               networkMonitor: mockNetworkMonitor,
                               loginError: JWTVerifierError.invalidJWTFormat)
    }
    
    private enum AuthenticationError: Error {
        case generic
    }
}

extension LoginCoordinatorTests {
    // MARK: Login
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
    
    func test_start_reauth() throws {
        // WHEN the LoginCoordinator is started in a reauth flow
        reauthLogin()
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
        let warningScreen = try XCTUnwrap(sut.root.presentedViewController as? GDSErrorViewController)
        XCTAssertTrue(warningScreen.viewModel is SignOutWarningViewModel)
    }
    
    func test_start_error() throws {
        // WHEN the LoginCoordinator is started in a reauth flow
        errorLogin()
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
        let warningScreen = try XCTUnwrap(sut.root.presentedViewController as? GDSErrorViewController)
        XCTAssertTrue(warningScreen.viewModel is UnableToLoginErrorViewModel)
    }
    
    func test_authenticate_missingPersistenId() throws {
        mockOpenSecureStore.returnFromCheckItemExists = false
        mockDefaultStore.set(true, forKey: .returningUser)
        let exp = XCTNSNotificationExpectation(name: Notification.Name(.clearWallet),
                                               object: nil,
                                               notificationCenter: NotificationCenter.default)
        // WHEN the LoginCoordinator is started and the persistent session id is missing
        sut.authenticate()
        // THEN the clear wallet notification should be posted
        wait(for: [exp], timeout: 20)
    }
    
    func test_authenticate_opensAuthenticationCoordinator() throws {
        // WHEN the LoginCoordinator is started
        sut.authenticate()
        // THEN the AuthenticationCoordinator should be launched
        XCTAssertTrue(sut.childCoordinators.last is AuthenticationCoordinator)
    }
    
    func test_authenticate_noNetwork() throws {
        // GIVEN the network is not connected
        mockNetworkMonitor.isConnected = false
        // WHEN the LoginCoordinator is started for a first time user
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
        let onboardingCoordinator = OnboardingCoordinator(analyticsPreferenceStore: mockAnalyticsPreferenceStore,
                                                          urlOpener: MockURLOpener())
        // GIVEN the LoginCoordinator has started and set it's view controllers
        sut.start()
        // GIVEN the LoginCoordinator regained focus from the OnboardingCoordinator
        sut.didRegainFocus(fromChild: onboardingCoordinator)
        // THEN the LoginCoordinator should still have IntroViewController as it's top view controller
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
    }
    
    func test_didRegainFocus_fromAuthenticationCoordinator_expiredToken() throws {
        reauthLogin()
        let tokenResponse = try MockTokenResponse().getJSONData()
        TokenHolder.shared.tokenResponse = tokenResponse
        TokenHolder.shared.idTokenPayload = try MockTokenVerifier().extractPayload("test")
        let authCoordinator = AuthenticationCoordinator(window: appWindow,
                                                        root: navigationController,
                                                        analyticsService: mockAnalyticsService,
                                                        userStore: mockUserStore,
                                                        session: MockLoginSession(),
                                                        reauth: false)
        // GIVEN the LoginCoordinator regained focus from the AuthenticationCoordinator
        sut.didRegainFocus(fromChild: authCoordinator)
        // THEN the LoginCoordinator should still have IntroViewController as it's top view controller
        XCTAssertEqual(try mockSecureStore.readItem(itemName: .accessToken), tokenResponse.accessToken)
        XCTAssertEqual(try mockSecureStore.readItem(itemName: .idToken), tokenResponse.idToken)
        XCTAssertEqual(try mockOpenSecureStore.readItem(itemName: .persistentSessionID), TokenHolder.shared.idTokenPayload?.persistentId)
        XCTAssertEqual(mockDefaultStore.value(forKey: .accessTokenExpiry) as? Date, tokenResponse.expiryDate)
        XCTAssertEqual(mockDefaultStore.value(forKey: .returningUser) as? Bool, true)
    }
    
    func test_didRegainFocus_fromAuthenticationCoordinator_withError() throws {
        let authCoordinator = AuthenticationCoordinator(window: appWindow,
                                                        root: navigationController,
                                                        analyticsService: mockAnalyticsService,
                                                        userStore: mockUserStore,
                                                        session: MockLoginSession(),
                                                        reauth: false)
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
