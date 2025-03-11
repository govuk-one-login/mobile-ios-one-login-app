import Networking
@testable import OneLogin
import XCTest

@MainActor
final class WalletCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var sut: WalletCoordinator!
    
    override func setUp() {
        super.setUp()

        window = UIWindow()
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        sut = WalletCoordinator(window: window,
                                analyticsService: mockAnalyticsService,
                                networkClient: NetworkClient(),
                                sessionManager: mockSessionManager)
    }
    
    override func tearDown() {
        window = nil
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
        let walletTab = UITabBarItem(title: "Wallet",
                                     image: UIImage(systemName: "wallet.pass"),
                                     tag: 1)
        XCTAssertEqual(sut.root.tabBarItem.title, walletTab.title)
        XCTAssertEqual(sut.root.tabBarItem.image, walletTab.image)
        XCTAssertEqual(sut.root.tabBarItem.tag, walletTab.tag)
    }
    
    func test_deleteWalletData() throws {
        // WHEN the deleteWalletData method is called
        // THEN no error should be thrown
        XCTAssertNoThrow(try sut.deleteWalletData())
    }
}
