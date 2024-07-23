@testable import OneLogin
import XCTest

@MainActor
final class WalletCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAuthenticatedStore: MockSecureStoreService!
    var mockOpenStore: MockSecureStoreService!
    var mockDefaultsStore: MockDefaultsStore!
    var mockUserStore: MockUserStore!
    var sut: WalletCoordinator!
    
    override func setUp() {
        super.setUp()
        
        window = UIWindow()
        mockAnalyticsService = MockAnalyticsService()
        mockAuthenticatedStore = MockSecureStoreService()
        mockOpenStore = MockSecureStoreService()
        mockDefaultsStore = MockDefaultsStore()
        mockUserStore = MockUserStore(authenticatedStore: mockAuthenticatedStore,
                                      openStore: mockOpenStore,
                                      defaultsStore: mockDefaultsStore)
        sut = WalletCoordinator(window: window,
                                analyticsService: mockAnalyticsService,
                                userStore: mockUserStore)
    }
    
    override func tearDown() {
        window = nil
        mockAnalyticsService = nil
        mockAnalyticsService = nil
        mockOpenStore = nil
        mockDefaultsStore = nil
        mockUserStore = nil
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
