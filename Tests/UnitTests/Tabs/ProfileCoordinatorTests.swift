import GDSCommon
@testable import OneLogin
import SecureStore
import XCTest

@MainActor
final class ProfileCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSecureStoreService: MockSecureStoreService!
    var mockOpenSecureStoreService: MockSecureStoreService!
    var mockDefaultStore: MockDefaultsStore!
    var mockUserStore: UserStorage!
    var urlOpener: URLOpener!
    var sut: ProfileCoordinator!
    
    override func setUp() {
        super.setUp()
        
        window = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockSecureStoreService = MockSecureStoreService()
        mockOpenSecureStoreService = MockSecureStoreService()
        mockDefaultStore = MockDefaultsStore()
        mockUserStore = UserStorage(authenticatedStore: mockSecureStoreService,
                                    openStore: mockOpenSecureStoreService,
                                    defaultsStore: mockDefaultStore)
        urlOpener = MockURLOpener()
        sut = ProfileCoordinator(analyticsService: mockAnalyticsService,
                                 userStore: mockUserStore,
                                 urlOpener: urlOpener)
        window.rootViewController = sut.root
        window.makeKeyAndVisible()
    }
    
    override func tearDown() {
        window = nil
        mockAnalyticsService = nil
        mockSecureStoreService = nil
        mockOpenSecureStoreService = nil
        mockDefaultStore = nil
        mockUserStore = nil
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
        TokenHolder.shared.idTokenPayload = MockTokenVerifier.mockPayload
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
        sut.start()
        sut.openSignOutPage()
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        // WHEN the user signs out
        let signOutButton: UIButton = try XCTUnwrap(presentedVC.topViewController?.view[child: "instructions-button"])
        signOutButton.sendActions(for: .touchUpInside)
        waitForTruth(self.sut.root.presentedViewController == nil, timeout: 20)
    }
}
