import Networking
@testable import OneLogin
import XCTest

@MainActor
final class HomeCoordinatorTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockNetworkClient: NetworkClient!
    var sut: HomeCoordinator!
    
    override func setUp() {
        super.setUp()

        mockAnalyticsService = MockAnalyticsService()
        mockNetworkClient = NetworkClient()
        sut = HomeCoordinator(analyticsService: mockAnalyticsService,
                              networkClient: mockNetworkClient)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        sut = nil
        
        super.tearDown()
    }
    
    func test_tabBarItem() throws {
        // WHEN the HomeCoordinator has started
        sut.start()
        // THEN the bar button item of the root is correctly configured
        let homeTab = UITabBarItem(title: "Home",
                                   image: UIImage(systemName: "house"),
                                   tag: 0)
        XCTAssertEqual(sut.root.tabBarItem.title, homeTab.title)
        XCTAssertEqual(sut.root.tabBarItem.image, homeTab.image)
        XCTAssertEqual(sut.root.tabBarItem.tag, homeTab.tag)
    }
}
