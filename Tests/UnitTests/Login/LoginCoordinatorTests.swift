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
    var mockNetworkMonitor: NetworkMonitoring!
    var mockSecureStore: MockSecureStoreService!
    var mockOpenSecureStore: MockSecureStoreService!
    var mockDefaultStore: MockDefaultsStore!
    var mockUserStore: UserStorage!
    var sut: LoginCoordinator!
    
    override func setUp() {
        super.setUp()
        
        appWindow = UIWindow()
        navigationController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = AnalyticsCenter(analyticsService: mockAnalyticsService,
                                              analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockNetworkMonitor = MockNetworkMonitor()
        mockSecureStore = MockSecureStoreService()
        mockOpenSecureStore = MockSecureStoreService()
        mockDefaultStore = MockDefaultsStore()
        mockUserStore = UserStorage(authenticatedStore: mockSecureStore,
                                    openStore: mockOpenSecureStore,
                                    defaultsStore: mockDefaultStore)
        appWindow.rootViewController = navigationController
        appWindow.makeKeyAndVisible()
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsCenter: mockAnalyticsCenter,
                               userStore: mockUserStore,
                               networkMonitor: mockNetworkMonitor,
                               reauth: false)
    }
    
    override func tearDown() {
        navigationController = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCenter = nil
        mockNetworkMonitor = nil
        mockSecureStore = nil
        mockOpenSecureStore = nil
        mockDefaultStore = nil
        mockUserStore = nil
        sut = nil
        
        super.tearDown()
    }
    
    func reauthLogin() {
        sut = LoginCoordinator(appWindow: appWindow,
                               root: navigationController,
                               analyticsCenter: mockAnalyticsCenter,
                               userStore: mockUserStore,
                               networkMonitor: mockNetworkMonitor,
                               reauth: true)
    }
    
    func loginWithError(_ error: Error) {
        let lc = LoginCoordinator(appWindow: appWindow,
                                  root: navigationController,
                                  analyticsCenter: mockAnalyticsCenter,
                                  userStore: mockUserStore,
                                  networkMonitor: mockNetworkMonitor,
                                  reauth: false)
        lc.loginError = error
        sut = lc
    }
    
    private enum AuthenticationError: Error {
        case generic
    }
}

extension LoginCoordinatorTests {
    // MARK: Reauth Login
    func test_start_reauth() {
        // WHEN the LoginCoordinator is started in a reauth flow
        reauthLogin()
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
    }
    
    func test_start_reauth_missingPersistenId() throws {
        mockOpenSecureStore.returnFromCheckItemExists = false
        mockDefaultStore.set(true, forKey: .returningUser)
        let exp = XCTNSNotificationExpectation(name: Notification.Name(.clearWallet),
                                               object: nil,
                                               notificationCenter: NotificationCenter.default)
        // WHEN the LoginCoordinator is started with an error and the persistent session id is missing
        reauthLogin()
        sut.start()
        // THEN the presented view controller should be the GDSErrorViewController
        let errorVC = try XCTUnwrap(sut.root.topViewController as? GDSErrorViewController)
        // THEN the visible view model should be the SignOutWarningViewModel
        XCTAssertTrue(errorVC.viewModel is SignOutWarningViewModel)
        let errorButton: UIButton = try XCTUnwrap(errorVC.view[child: "error-primary-button"])
        // WHEN the button to login is tapped
        errorButton.sendActions(for: .touchUpInside)
        // THEN the clear wallet notification should be posted
        wait(for: [exp], timeout: 20)
    }
    
    func test_start_reauth_opensAuthenticationCoordinator() throws {
        // WHEN the LoginCoordinator is started in a reauth flow
        reauthLogin()
        sut.start()
        // THEN the presented view controller should be the GDSErrorViewController
        let errorVC = try XCTUnwrap(sut.root.topViewController as? GDSErrorViewController)
        // THEN the visible view model should be the SignOutWarningViewModel
        XCTAssertTrue(errorVC.viewModel is SignOutWarningViewModel)
        let errorButton: UIButton = try XCTUnwrap(errorVC.view[child: "error-primary-button"])
        // WHEN the button to login is tapped
        errorButton.sendActions(for: .touchUpInside)
        // THEN the AuthenticationCoordinator should be launched
        XCTAssertTrue(sut.childCoordinators.last is AuthenticationCoordinator)
    }
    
    func test_start_reauth_noNetwork() throws {
        // GIVEN the network is not connected
        mockNetworkMonitor.isConnected = false
        // WHEN the LoginCoordinator is started in a reauth flow
        reauthLogin()
        sut.start()
        // THEN the visible view controller should be the GDSErrorViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        // WHEN the button to login is tapped
        let introScreen = try XCTUnwrap(sut.root.topViewController as? GDSErrorViewController)
        let introButton: UIButton = try XCTUnwrap(introScreen.view[child: "error-primary-button"])
        introButton.sendActions(for: .touchUpInside)
        // THEN the displayed screen should be the Network Connection error screen
        waitForTruth(self.sut.root.viewControllers.count == 2, timeout: 20)
        XCTAssertTrue(sut.root.topViewController is GDSErrorViewController)
        // WHEN the network is back online
        mockNetworkMonitor.isConnected = true
        let errorScreen = try XCTUnwrap(sut.root.topViewController as? GDSErrorViewController)
        XCTAssertTrue(errorScreen.viewModel is NetworkConnectionErrorViewModel)
        let errorButton: UIButton = try XCTUnwrap(errorScreen.view[child: "error-primary-button"])
        // WHEN the network error screens button is pressed
        errorButton.sendActions(for: .touchUpInside)
        // THEN the AuthenticationCoordinator is launched
        XCTAssertTrue(sut.childCoordinators.last is AuthenticationCoordinator)
    }
    
    // MARK: Standard Login
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
    
    func test_start_missingPersistenId() throws {
        mockOpenSecureStore.returnFromCheckItemExists = false
        mockDefaultStore.set(true, forKey: .returningUser)
        let exp = XCTNSNotificationExpectation(name: Notification.Name(.clearWallet),
                                               object: nil,
                                               notificationCenter: NotificationCenter.default)
        // WHEN the LoginCoordinator is started and the persistent session id is missing
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
        // WHEN the button to login is tapped
        let introScreen = try XCTUnwrap(sut.root.topViewController as? IntroViewController)
        let introButton: UIButton = try XCTUnwrap(introScreen.view[child: "intro-button"])
        introButton.sendActions(for: .touchUpInside)
        // THEN the clear wallet notification should be posted
        wait(for: [exp], timeout: 20)
    }
    
    func test_start_opensAuthenticationCoordinator() throws {
        // WHEN the LoginCoordinator is started
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.topViewController is IntroViewController)
        // WHEN the button to login is tapped
        let introScreen = try XCTUnwrap(sut.root.topViewController as? IntroViewController)
        let introButton: UIButton = try XCTUnwrap(introScreen.view[child: "intro-button"])
        introButton.sendActions(for: .touchUpInside)
        // THEN the AuthenticationCoordinator should be launched
        XCTAssertTrue(sut.childCoordinators.last is AuthenticationCoordinator)
    }
    
    func test_start_noNetwork() throws {
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
        // WHEN the network is back online
        mockNetworkMonitor.isConnected = true
        let errorScreen = try XCTUnwrap(sut.root.topViewController as? GDSErrorViewController)
        XCTAssertTrue(errorScreen.viewModel is NetworkConnectionErrorViewModel)
        let errorButton: UIButton = try XCTUnwrap(errorScreen.view[child: "error-primary-button"])
        // WHEN the network error screens button is pressed
        errorButton.sendActions(for: .touchUpInside)
        // THEN the intro screens button is enabled
        XCTAssertTrue(introButton.isEnabled)
        // THEN the AuthenticationCoordinator is launched
        XCTAssertTrue(sut.childCoordinators.last is AuthenticationCoordinator)
    }
    
    // MARK: Login with error
    func test_start_withError_tokenError_expired_opensOnboardingCoordinator() throws {
        // WHEN the LoginCoordinator is started with an error
        loginWithError(TokenError.expired)
        sut.start()
        // THEN the presented view controller should be the GDSErrorViewController
        let errorVC = try XCTUnwrap(sut.root.presentedViewController as? GDSErrorViewController)
        // THEN the visible view model should be the SignOutWarningViewModel
        XCTAssertTrue(errorVC.viewModel is SignOutWarningViewModel)
        let errorButton: UIButton = try XCTUnwrap(errorVC.view[child: "error-primary-button"])
        // WHEN the button to login is tapped
        errorButton.sendActions(for: .touchUpInside)
        // THEN the clear wallet notification should be posted
        XCTAssertTrue(sut.childCoordinators[0] is OnboardingCoordinator)
    }
    
    func test_start_withError_tokenError_expired_missingPersistentSessionId() throws {
        mockOpenSecureStore.returnFromCheckItemExists = false
        mockDefaultStore.set(true, forKey: .returningUser)
        let exp = XCTNSNotificationExpectation(name: Notification.Name(.clearWallet),
                                               object: nil,
                                               notificationCenter: NotificationCenter.default)
        // WHEN the LoginCoordinator is started with an error and the persistent session id is missing
        loginWithError(TokenError.expired)
        sut.start()
        // THEN the presented view controller should be the GDSErrorViewController
        let errorVC = try XCTUnwrap(sut.root.presentedViewController as? GDSErrorViewController)
        // THEN the visible view model should be the SignOutWarningViewModel
        XCTAssertTrue(errorVC.viewModel is SignOutWarningViewModel)
        let errorButton: UIButton = try XCTUnwrap(errorVC.view[child: "error-primary-button"])
        // WHEN the button to login is tapped
        errorButton.sendActions(for: .touchUpInside)
        // THEN the clear wallet notification should be posted
        wait(for: [exp], timeout: 20)
    }
    
    func test_start_withError_generic() throws {
        // WHEN the LoginCoordinator is started with an error
        loginWithError(AuthenticationError.generic)
        sut.start()
        // THEN the visible view controller should be the GDSErrorViewController
        waitForTruth(self.sut.root.topViewController is GDSErrorViewController, timeout: 20)
        let errroVC = try XCTUnwrap(sut.root.topViewController as? GDSErrorViewController)
        // THEN the visible view model should be the UnableToLoginErrorViewModel
        XCTAssertTrue(errroVC.viewModel is UnableToLoginErrorViewModel)
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
                                                        session: MockLoginSession())
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
