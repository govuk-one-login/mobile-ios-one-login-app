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
        mockNetworkMonitor = MockNetworkMonitor.shared
        window.rootViewController = navigationController
        sut = MainCoordinator(window: window,
                              root: navigationController,
                              networkMonitor: mockNetworkMonitor)
    }
    
    override func tearDown() {
        window = nil
        navigationController = nil
        sut = nil
        
        super.tearDown()
    }
}

extension MainCoordinatorTests {
    func test_mainCoordinatorStart_displaysIntroViewController() throws {
        // WHEN the MainCoordinator is stared
        XCTAssertTrue(navigationController.viewControllers.count == 0)
        sut.start()
        // THEN the visible view controller should be an IntroViewController
        XCTAssertTrue(navigationController.viewControllers.count == 1)
        XCTAssert(navigationController.topViewController is IntroViewController)
    }
    
    func test_mainCoordinatorStart_opensSubCoordinator() throws {
        // GIVEN the MainCoordinator is stared
        sut.start()
        // WHEN the button on the IntroViewController is tapped
        let introScreen = navigationController.topViewController as? IntroViewController
        let introButton: UIButton = try XCTUnwrap(introScreen?.view[child: "intro-button"])
        XCTAssertEqual(sut.childCoordinators.count, 0)
        introButton.sendActions(for: .touchUpInside)
        // THEN the MainCoordinator should have an AuthenticationCoordinator as it's only child coordinator
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
    
    // When user is offline display error screen
    func test_mainCoordinatorStart_displaysNetworkConnectionError() throws {
        // GIVEN user if offline
        mockNetworkMonitor.isConnected = false
        // GIVEN the MainCoordinator is started
        sut.start()
        // WHEN the button on the IntroViewController is tapped
        let introScreen = navigationController.topViewController as? IntroViewController
        let introButton: UIButton = try XCTUnwrap(introScreen?.view[child: "intro-button"])
        XCTAssertEqual(sut.childCoordinators.count, 0)
        introButton.sendActions(for: .touchUpInside)
        
        // THEN the network error screen is shown
        let vc = navigationController.topViewController as? GDSErrorViewController
        XCTAssertTrue(vc != nil)
        XCTAssertTrue(vc?.viewModel is NetworkConnectionErrorViewModel)
    }
    
    // When user is offline and error screen is show, but they try again whilst being online
    
    // When user is online and open Auth, but then loses connection

}
