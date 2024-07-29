@testable import OneLogin
import XCTest

@MainActor
final class WalletCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockAnalyticsCenter: AnalyticsCentral!
    var mockAuthenticatedStore: MockSecureStoreService!
    var mockOpenStore: MockSecureStoreService!
    var mockDefaultsStore: MockDefaultsStore!
    var mockUserStore: MockUserStore!
    var sut: WalletCoordinator!
    
    override func setUp() {
        super.setUp()
        
        TokenHolder.shared.clearTokenHolder()
        window = UIWindow()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                  analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockAuthenticatedStore = MockSecureStoreService()
        mockOpenStore = MockSecureStoreService()
        mockDefaultsStore = MockDefaultsStore()
        mockUserStore = MockUserStore(authenticatedStore: mockAuthenticatedStore,
                                      openStore: mockOpenStore,
                                      defaultsStore: mockDefaultsStore)
        sut = WalletCoordinator(window: window,
                                analyticsCenter: mockAnalyticsCenter,
                                userStore: mockUserStore)
    }
    
    override func tearDown() {
        TokenHolder.shared.clearTokenHolder()
        window = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCenter = nil
        mockAuthenticatedStore = nil
        mockOpenStore = nil
        mockDefaultsStore = nil
        mockUserStore = nil
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
    
    func test_handleUniversalLink() {
        // WHEN the handleUniversalLink method is called
        // This test is purely to get test coverage atm as we will not be able to test for effects on unmocked subcoordinators
        sut.handleUniversalLink(URL(string: "google.com")!)
    }
    
    func test_deleteWalletData() throws {
        // WHEN the deleteWalletData method is called
        // THEN no error should be thrown
        XCTAssertNoThrow(try sut.deleteWalletData())
    }
    
    func test_clearWallet() throws {
        sut.start()
        // WHEN there is a persistent session id saved, returning user is true and analytics preferences have been accepted
        try mockOpenStore.saveItem(item: "123456789", itemName: .persistentSessionID)
        mockDefaultsStore.set(true, forKey: .returningUser)
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        // WHEN the clearWallet notification is posted
        NotificationCenter.default.post(name: Notification.Name(.clearWallet), object: nil)
        // THEN the persistent session id, returning user and analytics preferences have been removed
        XCTAssertFalse(mockOpenStore.checkItemExists(itemName: .persistentSessionID))
        XCTAssertNil(mockDefaultsStore.value(forKey: .returningUser))
        XCTAssertNil(mockAnalyticsPreferenceStore.hasAcceptedAnalytics)
    }
    
    func test_clearWallet_error() throws {
        UserDefaults.standard.setValue(true, forKey: FeatureFlags.enableClearWalletError.rawValue)
        sut.start()
        // WHEN there is a persistent session id saved, returning user is true and analytics preferences have been accepted
        try mockOpenStore.saveItem(item: "123456789", itemName: .persistentSessionID)
        mockDefaultsStore.set(true, forKey: .returningUser)
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        NotificationCenter.default.post(name: Notification.Name(.clearWallet), object: nil)
        // THEN the persistent session id, returning user and analytics preferences should not have been removed
        XCTAssertTrue(mockOpenStore.checkItemExists(itemName: .persistentSessionID))
        XCTAssertNotNil(mockDefaultsStore.value(forKey: .returningUser))
        XCTAssertNotNil(mockAnalyticsPreferenceStore.hasAcceptedAnalytics)
        UserDefaults.standard.removeObject(forKey: FeatureFlags.enableClearWalletError.rawValue)
    }
}
