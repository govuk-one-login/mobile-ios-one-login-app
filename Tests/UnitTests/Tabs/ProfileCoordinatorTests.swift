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
        
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreference = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                  analyticsPreferenceStore: mockAnalyticsPreference)
        mockSecureStore = MockSecureStoreService()
        mockDefaultStore = MockDefaultsStore()
        mockUserStore = MockUserStore(secureStoreService: mockSecureStore,
                                      defaultsStore: mockDefaultStore)
        urlOpener = MockURLOpener()
        window = .init()
        sut = ProfileCoordinator(analyticsCenter: mockAnalyticsCenter,
                                 urlOpener: urlOpener,
                                 userStore: mockUserStore)
    }

    override func tearDown() {
        mockAnalyticsService = nil
        mockAnalyticsCenter = nil
        mockAnalyticsPreference = nil
        mockUserStore = nil
        mockSecureStore = nil
        mockDefaultStore = nil
        urlOpener = nil
        window = nil
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
        window.rootViewController = sut.root
        window.makeKeyAndVisible()
        sut.openSignOutPage()
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue(presentedVC.topViewController is GDSInstructionsViewController)
    }

    // MARK: Make this test pass to check analytics is false
    // should this be testing analyticsService or Preference?
    func test_clearsAnalyticsPreference() throws {
        mockAnalyticsService.hasAcceptedAnalytics = true
        sut.start()
        sut.openSignOutPage()
        mockAnalyticsService.denyAnalyticsPermission()
        XCTAssertFalse(try hasAcceptedAnalytics)
    }

    //MARK: Test for clearing user store
    func test_clearsUserStore() throws {
        sut.start()
    }

    //MARK: test for clearing biometrics
}

 extension ProfileCoordinatorTests {
    var hasAcceptedAnalytics: Bool {
        get throws {
            try XCTUnwrap(mockAnalyticsService.hasAcceptedAnalytics)
        }
    }
 }
