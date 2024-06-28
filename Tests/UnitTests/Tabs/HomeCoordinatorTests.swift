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
    var mockTokenHolder: TokenHolder!
    var sut: HomeCoordinator!
    
    override func setUp() {
        super.setUp()
        
        window = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockSecureStoreService = MockSecureStoreService()
        mockOpenSecureStore = MockSecureStoreService()
        mockDefaultsStore = MockDefaultsStore()
        mockUserStore = MockUserStore(authenticatedStore: mockSecureStoreService,
                                      openStore: mockOpenSecureStore,
                                      defaultsStore: mockDefaultsStore)
        mockTokenHolder = TokenHolder()
        sut = HomeCoordinator(analyticsService: mockAnalyticsService,
                              userStore: mockUserStore,
                              tokenHolder: mockTokenHolder)
    }
    
    override func tearDown() {
        window = nil
        mockAnalyticsService = nil
        mockSecureStoreService = nil
        mockOpenSecureStore = nil
        mockDefaultsStore = nil
        mockUserStore = nil
        mockTokenHolder = nil
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
        sut.start()
        window.rootViewController = sut.root
        window.makeKeyAndVisible()
        sut.showDeveloperMenu()
        let presentedViewController = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue( presentedViewController.topViewController is DeveloperMenuViewController)
    }
    
    func test_networkClientInitialized() throws {
        sut.start()
        XCTAssertNil(sut.networkClient)
        // GIVEN we have a non-nil tokenHolder and access token
        mockTokenHolder.idTokenPayload = MockTokenVerifier.mockPayload
        sut.updateToken()
        try mockUserStore.saveItem("accessToken",
                                   itemName: .accessToken,
                                   storage: .authenticated)
        // THEN the networkClieint will be initialized when the developer menu is shown
        sut.showDeveloperMenu()
        XCTAssertNotNil(sut.networkClient)
    }
    
    func test_updateToken() throws {
        sut.start()
        let vc = try XCTUnwrap(sut.baseVc)
        XCTAssertEqual(try vc.emailLabel.text, "")
        mockTokenHolder.idTokenPayload = MockTokenVerifier.mockPayload
        sut.updateToken()
        XCTAssertEqual(try vc.emailLabel.text, "You’re signed in as\nmock@email.com")
    }
}
