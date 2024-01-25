import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class MainCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var navigationController: UINavigationController!
    var sut: MainCoordinator!
    var mockNetworkMonitor: NetworkMonitoring!
    
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
    func test_mainCoordinatorStart_displaysIntroViewController() throws {
        // WHEN the MainCoordinator is started
        XCTAssertTrue(sut.root.viewControllers.count == 0)
        sut.start()
        // THEN the visible view controller should be an IntroViewController
        XCTAssertTrue(sut.root.viewControllers.count == 1)
        XCTAssert(sut.root.topViewController is IntroViewController)
    }
    
    func test_mainCoordinatorStart_opensSubCoordinator() throws {
        // GIVEN the user is online
        mockNetworkMonitor.isConnected = true
        // GIVEN the MainCoordinator is started
        sut.start()
        // WHEN the button on the IntroViewController is tapped
        let introScreen = sut.root.topViewController as? IntroViewController
        let introButton: UIButton = try XCTUnwrap(introScreen?.view[child: "intro-button"])
        XCTAssertEqual(sut.childCoordinators.count, 0)
        introButton.sendActions(for: .touchUpInside)
        // THEN the MainCoordinator should have an AuthenticationCoordinator as it's only child coordinator
        waitForTruth(self.mockNetworkMonitor.isConnected, timeout: 2)
        XCTAssertTrue(sut.childCoordinators.first is AuthenticationCoordinator)
        XCTAssertEqual(sut.childCoordinators.count, 1)
    }
    
    func test_didRegainFocus_fromAuthenticationCoordinator() throws {
        let mockLoginSession = MockLoginSession()
        let mockErrorPresenter = ErrorPresenter.self
        let mockAnalyticsService = MockAnalyticsService()
        let child = AuthenticationCoordinator(root: navigationController,
                                              session: mockLoginSession,
                                              errorPresenter: mockErrorPresenter,
                                              analyticsService: mockAnalyticsService)
        sut.tokens = try MockTokenResponse().getJSONData()
        // GIVEN the MainCoordinator regained focus from it's child coordinator
        sut.didRegainFocus(fromChild: child)
        // THEN the MainCoordinator only child coordinator should be a TokenCooridnator
        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators.last is TokenCoordinator)
    }
    
    func test_mainCoordinatorStart_displaysNetworkConnectionError() throws {
        // GIVEN the user is offline
        mockNetworkMonitor.isConnected = false
        // GIVEN the MainCoordinator is started
        sut.start()
        // WHEN the button on the IntroViewController is tapped
        let introScreen = sut.root.topViewController as? IntroViewController
        let introButton: UIButton = try XCTUnwrap(introScreen?.view[child: "intro-button"])
        XCTAssertEqual(sut.childCoordinators.count, 0)
        introButton.sendActions(for: .touchUpInside)
        // THEN the network error screen is shown
        waitForTruth(!self.mockNetworkMonitor.isConnected, timeout: 2)
        let vc = sut.root.topViewController as? GDSErrorViewController
        XCTAssertTrue(vc != nil)
        XCTAssertTrue(vc?.viewModel is NetworkConnectionErrorViewModel)
    }
    
    func test_networkErrorScreen_reconnectingOpensAuthCoordinator() throws {
        // GIVEN the user is offline
        mockNetworkMonitor.isConnected = false
        // GIVEN the MainCoordinator is started
        sut.start()
        // WHEN the button on the IntroViewController is tapped
        let introScreen = sut.root.topViewController as? IntroViewController
        let introButton: UIButton = try XCTUnwrap(introScreen?.view[child: "intro-button"])
        XCTAssertEqual(sut.childCoordinators.count, 0)
        introButton.sendActions(for: .touchUpInside)
        // THEN the network error screen is shown
        waitForTruth(!self.mockNetworkMonitor.isConnected, timeout: 2)
        let vc = sut.root.topViewController as? GDSErrorViewController
        XCTAssertTrue(vc != nil)
        XCTAssertTrue(vc?.viewModel is NetworkConnectionErrorViewModel)
        // GIVEN the user is online
        mockNetworkMonitor.isConnected = true
        // WHEN the button on the error screen is tapped
        let errorPrimaryButton: UIButton = try XCTUnwrap(vc?.view[child: "error-primary-button"])
        errorPrimaryButton.sendActions(for: .touchUpInside)
        // THEN the MainCoordinator should have an AuthenticationCoordinator as it's only child coordinator
        XCTAssertTrue(sut.childCoordinators.first is AuthenticationCoordinator)
        XCTAssertEqual(sut.childCoordinators.count, 1)
    }
    
    func test_networkErrorScreen_popsToLogin() throws {
        // GIVEN the user is offline
        mockNetworkMonitor.isConnected = false
        // GIVEN the MainCoordinator is started
        sut.start()
        // WHEN the button on the IntroViewController is tapped
        let introScreen = sut.root.topViewController as? IntroViewController
        let introButton: UIButton = try XCTUnwrap(introScreen?.view[child: "intro-button"])
        XCTAssertEqual(sut.childCoordinators.count, 0)
        introButton.sendActions(for: .touchUpInside)
        // THEN the network error screen is shown
        waitForTruth(!self.mockNetworkMonitor.isConnected, timeout: 2)
        let vc = sut.root.topViewController as? GDSErrorViewController
        XCTAssertTrue(vc != nil)
        XCTAssertTrue(vc?.viewModel is NetworkConnectionErrorViewModel)
        // GIVEN the user is online
        // WHEN the button on the error screen is tapped
        let errorPrimaryButton: UIButton = try XCTUnwrap(vc?.view[child: "error-primary-button"])
        errorPrimaryButton.sendActions(for: .touchUpInside)
        // THEN the MainCoordinator shouldn't have launched it's AuthenticationCoordinator
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
}
