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
    
    func test_showDeveloperMenu() throws {
        window.rootViewController = sut.root
        window.makeKeyAndVisible()
        sut.start()
        // WHEN the showDeveloperMenu method is called
        sut.showDeveloperMenu()
        // THEN the presented view controller is the DeveloperMenuViewController
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
        // WHEN the HomeCoordinator is started
        sut.start()
        let vc = try XCTUnwrap(sut.baseVc)
        // THEN the email label should be nil
        XCTAssertEqual(try vc.emailLabel.text, "")
        // WHEN the token holder's idTokenPayload is populated
        TokenHolder.shared.idTokenPayload = MockTokenVerifier.mockPayload
        // WHEN the updateToken method is called
        sut.updateToken()
        // THEN the email label should contain te email from the email token
        XCTAssertEqual(try vc.emailLabel.text, "You’re signed in as\nmock@email.com")
    }
}
