@testable import OneLogin
import XCTest

@MainActor
final class HomeCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSecureStoreService: MockSecureStoreService!
    var mockOpenSecureStore: MockSecureStoreService!
    var mockDefaultsStore: MockDefaultsStore!
    var mockUserStore: MockUserStore!
    var sut: HomeCoordinator!
    
    override func setUp() {
        super.setUp()
        
        TokenHolder.shared.clearTokenHolder()
        window = UIWindow()
        mockAnalyticsService = MockAnalyticsService()
        mockSecureStoreService = MockSecureStoreService()
        mockOpenSecureStore = MockSecureStoreService()
        mockDefaultsStore = MockDefaultsStore()
        mockUserStore = MockUserStore(authenticatedStore: mockSecureStoreService,
                                      openStore: mockOpenSecureStore,
                                      defaultsStore: mockDefaultsStore)
        sut = HomeCoordinator(analyticsService: mockAnalyticsService,
                              userStore: mockUserStore)
    }
    
    override func tearDown() {
        TokenHolder.shared.clearTokenHolder()
        window = nil
        mockAnalyticsService = nil
        mockSecureStoreService = nil
        mockOpenSecureStore = nil
        mockDefaultsStore = nil
        mockUserStore = nil
        sut = nil
        
        super.tearDown()
    }
    
    func test_tabBarItem() throws {
        sut.start()
        let homeTab = UITabBarItem(title: "Home",
                                   image: UIImage(systemName: "house"),
                                   tag: 0)
        XCTAssertEqual(sut.root.tabBarItem.title, homeTab.title)
        XCTAssertEqual(sut.root.tabBarItem.image, homeTab.image)
        XCTAssertEqual(sut.root.tabBarItem.tag, homeTab.tag)
    }
    
    func test_showDeveloperMenu() throws {
        window.rootViewController = sut.root
        window.makeKeyAndVisible()
        sut.start()
        sut.showDeveloperMenu()
        let presentedViewController = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue(presentedViewController.topViewController is DeveloperMenuViewController)
    }
    
    func test_networkClientInitialized() throws {
        sut.start()
        // GIVEN we have a non-nil tokenHolder and access token
        TokenHolder.shared.idTokenPayload = MockTokenVerifier.mockPayload
        sut.updateToken()
        try mockUserStore.saveItem("accessToken",
                                   itemName: .accessToken,
                                   storage: .authenticated)
        // THEN the networkClieint will be initialized when the developer menu is shown
        sut.showDeveloperMenu()
    }
    
    func test_updateToken() throws {
        sut.start()
        let vc = try XCTUnwrap(sut.baseVc)
        XCTAssertEqual(try vc.emailLabel.text, "")
        TokenHolder.shared.idTokenPayload = MockTokenVerifier.mockPayload
        sut.updateToken()
        XCTAssertEqual(try vc.emailLabel.text, "You’re signed in as\nmock@email.com")
    }
}
