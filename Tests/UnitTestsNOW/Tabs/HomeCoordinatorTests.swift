@testable import OneLoginNOW
import XCTest

@MainActor
final class HomeCoordinatorTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockUserStore: MockUserStore!
    var window: UIWindow!
    var sut: HomeCoordinator!
    
    override func setUp() {
        super.setUp()
        
        mockAnalyticsService = MockAnalyticsService()
        mockUserStore = MockUserStore(secureStoreService: MockSecureStoreService(), defaultsStore: MockDefaultsStore())
        window = .init()
        sut = HomeCoordinator(analyticsService: mockAnalyticsService,
                              userStore: mockUserStore)
    }
    
    override func tearDown() {
        mockAnalyticsService = nil
        window = nil
        sut = nil
        mockUserStore = nil
        
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
        let tokenHolder = TokenHolder()
        tokenHolder.idTokenPayload = MockTokenVerifier.mockPayload
        sut.updateToken(tokenHolder)
        try mockUserStore.secureStoreService.saveItem(item: "accessToken", itemName: .accessToken)
        // THEN the networkClieint will be initialized when the developer menu is shown
        sut.showDeveloperMenu()
        XCTAssertNotNil(sut.networkClient)
    }
    
    func test_updateToken() throws {
        sut.start()
        let vc = try XCTUnwrap(sut.baseVc)
        XCTAssertEqual(try vc.emailLabel.text, "")
        let tokenHolder = TokenHolder()
        tokenHolder.idTokenPayload = MockTokenVerifier.mockPayload
        sut.updateToken(tokenHolder)
        XCTAssertEqual(try vc.emailLabel.text, "You’re signed in as\nmock@email.com")
    }
}
