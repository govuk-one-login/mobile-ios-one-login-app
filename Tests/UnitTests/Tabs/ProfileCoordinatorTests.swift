import GDSCommon
@testable import OneLogin
import SecureStore
import XCTest

@MainActor
final class ProfileCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreference: MockAnalyticsPreferenceStore!
    var mockAnalyticsCenter: MockAnalyticsCenter!
    var mockSecureStoreService: MockSecureStoreService!
    var mockDefaultStore: MockDefaultsStore!
    var mockUserStore: UserStorage!
    var tokenHolder: TokenHolder!
    var urlOpener: URLOpener!
    var sut: ProfileCoordinator!
    
    override func setUp() {
        super.setUp()
        
        window = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreference = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                  analyticsPreferenceStore: mockAnalyticsPreference)
        mockSecureStoreService = MockSecureStoreService()
        mockDefaultStore = MockDefaultsStore()
        mockUserStore = UserStorage(secureStoreService: mockSecureStoreService,
                                    defaultsStore: mockDefaultStore)
        tokenHolder = TokenHolder()
        urlOpener = MockURLOpener()
        sut = ProfileCoordinator(analyticsCenter: mockAnalyticsCenter,
                                 userStore: mockUserStore,
                                 tokenHolder: tokenHolder,
                                 urlOpener: urlOpener)
        window.rootViewController = sut.root
        window.makeKeyAndVisible()
    }
    
    override func tearDown() {
        window = nil
        mockAnalyticsService = nil
        mockAnalyticsPreference = nil
        mockAnalyticsCenter = nil
        mockSecureStoreService = nil
        mockDefaultStore = nil
        mockUserStore = nil
        tokenHolder = nil
        urlOpener = nil
        sut = nil
        
        super.tearDown()
    }
    
    func test_tabBarItem() {
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
        tokenHolder.idTokenPayload = MockTokenVerifier.mockPayload
        sut.updateToken()
        XCTAssertEqual(try vc.emailLabel.text, "You’re signed in as\nmock@email.com")
    }
    
    func test_openSignOutPage() throws {
        sut.start()
        sut.openSignOutPage()
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue(presentedVC.topViewController is GDSInstructionsViewController)
    }
    
    func test_tapSignoutClearsData() throws {
        // GIVEN the user is on the signout page
        mockAnalyticsService.hasAcceptedAnalytics = true
        sut.start()
        sut.openSignOutPage()
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue(presentedVC.topViewController is GDSInstructionsViewController)
        // WHEN the user signs out
        let signOutButton: UIButton = try XCTUnwrap(presentedVC.topViewController!.view[child: "instructions-button"])
        signOutButton.sendActions(for: .touchUpInside)
        // THEN all other user information will be deleted
        XCTAssertNil(mockAnalyticsPreference.hasAcceptedAnalytics)
    }
    
    func test_signoutErrorShowsErrorScreen() throws {
        UserDefaults.standard.set(true, forKey: "EnableSignoutError")
        // GIVEN the user is on the signout page
        sut.start()
        sut.openSignOutPage()
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue(presentedVC.topViewController is GDSInstructionsViewController)
        // IF there is an error on deleting the keys
        mockSecureStoreService.errorFromDeleteItem = SecureStoreError.cantDeleteKey
        // WHEN the user signs out
        let signOutButton: UIButton = try XCTUnwrap(presentedVC.topViewController!.view[child: "instructions-button"])
        signOutButton.sendActions(for: .touchUpInside)
        // THEN an error page will be shown
        waitForTruth(presentedVC.topViewController is GDSErrorViewController, timeout: 20)
        UserDefaults.standard.set(false, forKey: "EnableSignoutError")
    }
}

extension ProfileCoordinatorTests {
    var hasAcceptedAnalytics: Bool {
        get throws {
            try XCTUnwrap(mockAnalyticsService.hasAcceptedAnalytics)
        }
    }
}
