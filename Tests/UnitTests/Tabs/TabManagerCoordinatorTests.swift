import GDSAnalytics
import GDSCommon
import Networking
@testable import OneLogin
import XCTest

final class TabManagerCoordinatorTests: XCTestCase {
    var tabBarController: UITabBarController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var sut: TabManagerCoordinator!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        tabBarController = UITabBarController()
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        sut = TabManagerCoordinator(root: tabBarController,
                                    analyticsService: mockAnalyticsService,
                                    networkClient: NetworkClient(),
                                    sessionManager: mockSessionManager)
    }
    
    override func tearDown() {
        tabBarController = nil
        mockAnalyticsService = nil
        mockSessionManager = nil
        sut = nil
        
        super.tearDown()
    }
}

@MainActor
extension TabManagerCoordinatorTests {
    func test_start_performsSetUpWithWallet() async {
        // WHEN the TabManagerCoordinator is started
        sut.start()
        await sut.addTabTask?.value
        // THEN the TabManagerCoordinator should have child coordinators
        XCTAssertEqual(sut.childCoordinators.count, 3)
        XCTAssertTrue(sut.childCoordinators[0] is HomeCoordinator)
        XCTAssertTrue(sut.childCoordinators[1] is WalletCoordinator)
        XCTAssertTrue(sut.childCoordinators[2] is SettingsCoordinator)
    }
    
    func test_handleUniversalLink() async throws {
        sut.start()
        await sut.addTabTask?.value
        // WHEN the handleUniversalLink receives a deeplink
        let deeplink = try XCTUnwrap(URL(string: "google.co.uk/wallet"))
        await sut.handleUniversalLink(deeplink)
        // THEN the wallet tab should be added and the selected index should be 1
        XCTAssertTrue(sut.childCoordinators.contains(where: { $0 is WalletCoordinator }))
        XCTAssertTrue(sut.root.selectedIndex == 1)
    }
    
    func test_tabSwitching() async throws {
        sut.start()
        await sut.addTabTask?.value
        // start with home tab selected
        sut.root.selectedIndex = 0
        sut.updateSelectedTabIndex()
        XCTAssertEqual(sut.selectedTabIndex, 0)
        XCTAssertTrue(sut.isTabAlreadySelected())
        
        sut.root.selectedIndex = 1
        XCTAssertFalse(sut.isTabAlreadySelected())
    }
}
