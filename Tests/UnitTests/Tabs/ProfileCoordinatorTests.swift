import GDSCommon
@testable import OneLogin
import XCTest

@MainActor
final class ProfileCoordinatorTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsCenter: MockAnalyticsCenter!
    var mockAnalyticsPreference: MockAnalyticsPreferenceStore!
    var mockUserStore: MockUserStore!
    var mockSecureStore: MockSecureStoreService!
    var mockDefaultStore: MockDefaultsStore!
    var urlOpener: URLOpener!
    var window: UIWindow!
    var sut: ProfileCoordinator!
    
    override func setUp() {
        super.setUp()
        
        window = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreference = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                  analyticsPreferenceStore: mockAnalyticsPreference)
        urlOpener = MockURLOpener()
        mockSecureStore = MockSecureStoreService()
        mockDefaultStore = MockDefaultsStore()
        mockUserStore = MockUserStore(secureStoreService: mockSecureStore,
                                      defaultsStore: mockDefaultStore)
        sut = ProfileCoordinator(analyticsCenter: mockAnalyticsCenter,
                                 urlOpener: urlOpener,
                                 userStore: mockUserStore)
        window.rootViewController = sut.root
        window.makeKeyAndVisible()
    }
    
    override func tearDown() {
        window = nil
        mockAnalyticsService = nil
        mockAnalyticsPreference = nil
        mockAnalyticsCenter = nil
        urlOpener = nil
        mockSecureStore = nil
        mockDefaultStore = nil
        mockUserStore = nil
        sut = nil
        
        super.tearDown()
    }
    
    func test_tabBarItem() throws {
        sut.start()
        let profileTab = UITabBarItem(title: "Profile",
                                      image: UIImage(systemName: "person.crop.circle"),
                                      tag: 2)
        XCTAssertEqual(sut.root.tabBarItem.title, profileTab.title)
        XCTAssertEqual(sut.root.tabBarItem.image, profileTab.image)
        XCTAssertEqual(sut.root.tabBarItem.tag, profileTab.tag)
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
    
    func test_openSignOutPage() throws {
        sut.start()
        sut.openSignOutPage()
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue(presentedVC.topViewController is GDSInstructionsViewController)
    }
    
    func test_tapSignoutClearsData() throws {
        mockAnalyticsService.hasAcceptedAnalytics = true
        try mockUserStore.secureStoreService.saveItem(item: "accessToken", itemName: .accessToken)
        mockDefaultStore.set(Date(), forKey: .accessTokenExpiry)
        sut.start()
        sut.openSignOutPage()
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue(presentedVC.topViewController is GDSInstructionsViewController)
        let signOutButton: UIButton = try XCTUnwrap(presentedVC.topViewController!.view[child: "instructions-button"])
        signOutButton.sendActions(for: .touchUpInside)
        XCTAssertNil(try? mockUserStore.secureStoreService.readItem(itemName: .accessToken))
        XCTAssertNil(try? mockUserStore.secureStoreService.readItem(itemName: .idToken))
        XCTAssertNil(mockDefaultStore.value(forKey: .accessTokenExpiry))
        XCTAssertNil(mockAnalyticsPreference.hasAcceptedAnalytics)
    }
}

extension ProfileCoordinatorTests {
    var hasAcceptedAnalytics: Bool {
        get throws {
            try XCTUnwrap(mockAnalyticsService.hasAcceptedAnalytics)
        }
    }
}
