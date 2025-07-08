import GDSAnalytics
import Networking
@testable import OneLogin
import XCTest

@MainActor
final class WalletCoordinatorTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var sut: WalletCoordinator!
    
    override func setUp() {
        super.setUp()

        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        sut = WalletCoordinator(analyticsService: mockAnalyticsService,
                                networkClient: NetworkClient(),
                                sessionManager: mockSessionManager)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        mockSessionManager = nil
        sut = nil
        
        super.tearDown()
    }
}

extension WalletCoordinatorTests {
    func test_tabBarItem() throws {
        // WHEN the WalletCoordinator has started
        sut.start()
        // THEN the bar button item of the root is correctly configured
        let walletTab = UITabBarItem(title: "Documents",
                                     image: UIImage(systemName: "wallet.pass"),
                                     tag: 1)
        XCTAssertEqual(sut.root.tabBarItem.title, walletTab.title)
        XCTAssertEqual(sut.root.tabBarItem.image, walletTab.image)
        XCTAssertEqual(sut.root.tabBarItem.tag, walletTab.tag)
    }
    
    func test_didBecomeSelected() {
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 0)
        sut.didBecomeSelected()
        let event = IconEvent(textKey: "app_tabBarWallet")
        XCTAssertEqual(mockAnalyticsService.eventsLogged.count, 1)
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [event.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, event.parameters)
        XCTAssertNil(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level2] as? String)
        XCTAssertNil(mockAnalyticsService.additionalParameters[OLTaxonomyKey.level3] as? String)
    }
}
