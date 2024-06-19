@testable import OneLogin
import XCTest

@MainActor
final class WalletCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSecureStoreService: MockSecureStoreService!
    var mockTokenHolder: TokenHolder!

    var sut: WalletCoordinator!
    
    override func setUp() {
        super.setUp()
        
        window = UIWindow()
        mockAnalyticsService = MockAnalyticsService()
        mockSecureStoreService = MockSecureStoreService()
        mockTokenHolder = TokenHolder()
        sut = WalletCoordinator(window: window,
                                analyticsService: mockAnalyticsService,
                                secureStoreService: mockSecureStoreService,
                                tokenHolder: mockTokenHolder)
    }
    
    override func tearDown() {
        window = nil
        mockAnalyticsService = nil
        mockSecureStoreService = nil
        mockTokenHolder = nil
        sut = nil
        
        super.tearDown()
    }
}

extension WalletCoordinatorTests {
    func test_tabBarItem() throws {
        sut.start()
        let walletTab = UITabBarItem(title: "Wallet",
                                     image: UIImage(systemName: "wallet.pass"),
                                     tag: 1)
        XCTAssertEqual(sut.root.tabBarItem.title, walletTab.title)
        XCTAssertEqual(sut.root.tabBarItem.image, walletTab.image)
        XCTAssertEqual(sut.root.tabBarItem.tag, walletTab.tag)
    }
}
