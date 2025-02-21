import GDSCommon
import Networking
@testable import OneLogin
import SecureStore
import XCTest

@MainActor
final class ProfileCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreference: MockAnalyticsPreferenceStore!
    var mockSessionManager: MockSessionManager!
    var mockNetworkClient: NetworkClient!
    var urlOpener: URLOpener!
    var sut: ProfileCoordinator!
    
    override func setUp() {
        super.setUp()

        window = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreference =  MockAnalyticsPreferenceStore()
        mockSessionManager = MockSessionManager()
        mockNetworkClient = NetworkClient()
        urlOpener = MockURLOpener()
        sut = ProfileCoordinator(analyticsService: mockAnalyticsService,
                                 sessionManager: mockSessionManager,
                                 networkClient: mockNetworkClient,
                                 urlOpener: urlOpener,
                                 analyticsPreference: mockAnalyticsPreference)
        window.rootViewController = sut.root
        window.makeKeyAndVisible()
    }
    
    override func tearDown() {
        window = nil
        mockAnalyticsService = nil
        mockSessionManager = nil
        mockNetworkClient = nil
        urlOpener = nil
        sut = nil
        
        super.tearDown()
    }
    
    func test_tabBarItem() {
        // WHEN the ProfileCoordinator has started
        sut.start()
        let profileTab = UITabBarItem(title: "Profile",
                                      image: UIImage(systemName: "person.crop.circle"),
                                      tag: 2)
        // THEN the bar button item of the root is correctly configured
        XCTAssertEqual(sut.root.tabBarItem.title, profileTab.title)
        XCTAssertEqual(sut.root.tabBarItem.image, profileTab.image)
        XCTAssertEqual(sut.root.tabBarItem.tag, profileTab.tag)
    }
    
    func test_openSignOutPageWithWallet() throws {
        // WHEN Wallet has been accessed before
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: false],
            featureFlags: [:]
        )
        // WHEN the ProfileCoordinator is started
        sut.start()
        // WHEN the openSignOutPage method is called
        sut.openSignOutPage()
        // THEN the presented view controller is the GDSInstructionsViewController
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue(presentedVC.topViewController is GDSInstructionsViewController)
    }
    
    func test_openSignOutPageNoWallet() throws {
        // WHEN the ProfileCoordinator is started
        sut.start()
        // WHEN the openSignOutPage method is called
        sut.openSignOutPage()
        // THEN the presented view controller is the GDSInstructionsViewController
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue(presentedVC.topViewController is GDSInstructionsViewController)
    }
    
    func test_tapSignoutClearsData() throws {
        // GIVEN the user is on the signout page
        sut.start()
        // WHEN the openSignOutPage method is called
        sut.openSignOutPage()
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        // WHEN the user signs out
        let signOutButton: UIButton = try XCTUnwrap(presentedVC.topViewController?.view[child: "instructions-button"])
        signOutButton.sendActions(for: .touchUpInside)
        // THEN the presented view controller should be dismissed
        waitForTruth(self.sut.root.presentedViewController == nil, timeout: 20)
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
}
