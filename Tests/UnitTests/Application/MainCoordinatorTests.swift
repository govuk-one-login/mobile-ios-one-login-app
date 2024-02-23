import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class MainCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var navigationController: UINavigationController!
    var mockNetworkMonitor: NetworkMonitoring!
    var sut: MainCoordinator!
    
    override func setUp() {
        super.setUp()
        
        window = .init()
        navigationController = .init()
        mockNetworkMonitor = MockNetworkMonitor()
        window.rootViewController = navigationController
        sut = MainCoordinator(window: window,
                              root: navigationController,
                              networkMonitor: mockNetworkMonitor)
    }
    
    override func tearDown() {
        window = nil
        navigationController = nil
        mockNetworkMonitor = nil
        sut = nil
        
        super.tearDown()
    }
}

extension MainCoordinatorTests {
    func test_start_displaysIntroViewController() throws {
        // WHEN the MainCoordinator is started
        XCTAssertTrue(sut.root.viewControllers.count == 0)
        sut.start()
        // THEN the visible view controller should be the IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssert(sut.root.topViewController is IntroViewController)
    }
    
    func test_start_opensAuthenticationCoordinator() throws {
        // WHEN the MainCoordinator is started
        sut.start()
        // WHEN the button on the IntroViewController is tapped
        let introScreen = try XCTUnwrap(navigationController.topViewController as? IntroViewController)
        let introButton: UIButton = try XCTUnwrap(introScreen.view[child: "intro-button"])
        XCTAssertEqual(sut.childCoordinators.count, 0)
        introButton.sendActions(for: .touchUpInside)
        // THEN the MainCoordinator should have an AuthenticationCoordinator as it's only child coordinator
        waitForTruth(self.sut.childCoordinators.count == 1, timeout: 5)
        XCTAssertTrue(sut.childCoordinators.last is AuthenticationCoordinator)
    }
    
    func test_start_displaysNetworkConnectionError() throws {
        // GIVEN the user is offline
        mockNetworkMonitor.isConnected = false
        // WHEN the MainCoordinator is started
        sut.start()
        // WHEN the button on the IntroViewController is tapped
        let introScreen = try XCTUnwrap(navigationController.topViewController as? IntroViewController)
        let introButton: UIButton = try XCTUnwrap(introScreen.view[child: "intro-button"])
        XCTAssertEqual(sut.childCoordinators.count, 0)
        introButton.sendActions(for: .touchUpInside)
        // THEN the 'network' error screen is shown
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is NetworkConnectionErrorViewModel)
    }
    
    func test_didRegainFocus_fromAuthenticationCoordinator() throws {
        let mockLoginSession = MockLoginSession()
        let mockAnalyticsService = MockAnalyticsService()
        let tokenHolder = TokenHolder()
        let child = AuthenticationCoordinator(root: navigationController,
                                              session: mockLoginSession,
                                              analyticsService: mockAnalyticsService,
                                              tokenHolder: tokenHolder)
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // GIVEN the MainCoordinator regained focus from the AuthenticationCoordinator
        sut.didRegainFocus(fromChild: child)
        // THEN the MainCoordinator should have an OnboardingCoordinator as it's only child coordinator
        waitForTruth(self.sut.childCoordinators.count == 1, timeout: 2)
        XCTAssertTrue(sut.childCoordinators.last is TokenCoordinator)
    }
    
    func test_didRegainFocus_fromOnboardingCoordinator() throws {
        let mockAnalyticsService = MockAnalyticsService()
        let tokenHolder = TokenHolder()
        let mockSecureStore = MockSecureStoreService()
        let mockDefaultsStore = MockDefaultsStore()
        let mockUserStore = MockUserStore(secureStoreService: mockSecureStore,
                                          defaultsStore: mockDefaultsStore)
        let child = OnboardingCoordinator(root: navigationController,
                                          userStore: mockUserStore,
                                          analyticsService: mockAnalyticsService,
                                          tokenHolder: tokenHolder)
        sut.tokenHolder.tokenResponse = try MockTokenResponse().getJSONData()
        // GIVEN the MainCoordinator regained focus from the OnboardingCoordinator
        sut.didRegainFocus(fromChild: child)
        // THEN the MainCoordinator only child coordinator should be a TokenCooridnator
        waitForTruth(self.sut.childCoordinators.count == 1, timeout: 2)
        XCTAssertTrue(sut.childCoordinators.last is TokenCoordinator)
    }
    
    func test_networkErrorScreen_reconnectingOpensAuthCoordinator() throws {
        // GIVEN the user is offline
        mockNetworkMonitor.isConnected = false
        // WHEN the MainCoordinator is started
        sut.start()
        // WHEN the button on the IntroViewController is tapped
        let introScreen = try XCTUnwrap(navigationController.topViewController as? IntroViewController)
        let introButton: UIButton = try XCTUnwrap(introScreen.view[child: "intro-button"])
        XCTAssertEqual(sut.childCoordinators.count, 0)
        introButton.sendActions(for: .touchUpInside)
        // THEN the 'network' error screen is shown
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is NetworkConnectionErrorViewModel)
        // GIVEN the user is online
        mockNetworkMonitor.isConnected = true
        // WHEN the button on the error screen is tapped
        let errorPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "error-primary-button"])
        errorPrimaryButton.sendActions(for: .touchUpInside)
        // THEN the MainCoordinator should have an AuthenticationCoordinator
        // as it's only child coordinator
        waitForTruth(self.sut.childCoordinators.count == 1, timeout: 5)
        XCTAssertTrue(sut.childCoordinators.last is AuthenticationCoordinator)
    }
    
    func test_networkErrorScreen_popsToLogin() throws {
        // GIVEN the user is offline
        mockNetworkMonitor.isConnected = false
        // WHEN the MainCoordinator is started
        sut.start()
        // WHEN the button on the IntroViewController is tapped
        let introScreen = try XCTUnwrap(navigationController.topViewController as? IntroViewController)
        let introButton: UIButton = try XCTUnwrap(introScreen.view[child: "intro-button"])
        XCTAssertEqual(sut.childCoordinators.count, 0)
        introButton.sendActions(for: .touchUpInside)
        // THEN the network error screen is shown
        waitForTruth(self.navigationController.viewControllers.count == 2, timeout: 2)
        let vc = try XCTUnwrap(navigationController.topViewController as? GDSErrorViewController)
        XCTAssertTrue(vc.viewModel is NetworkConnectionErrorViewModel)
        // GIVEN the user is online
        // WHEN the button on the error screen is tapped
        let errorPrimaryButton: UIButton = try XCTUnwrap(vc.view[child: "error-primary-button"])
        errorPrimaryButton.sendActions(for: .touchUpInside)
        // THEN the MainCoordinator shouldn't have launched it's AuthenticationCoordinator
        waitForTruth(self.sut.childCoordinators.count == 0, timeout: 2)
    }
}
