import GDSCommon
import Networking
@testable import OneLogin
import SecureStore
import XCTest

@MainActor
final class SettingsCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreference: MockAnalyticsPreferenceStore!
    var mockAnalyticsCenter: MockAnalyticsCenter!
    var mockSessionManager: MockSessionManager!
    var mockNetworkClient: NetworkClient!
    var urlOpener: URLOpener!
    var sut: SettingsCoordinator!
    
    override func setUp() {
        super.setUp()
        
        window = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreference =  MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                  analyticsPreferenceStore: mockAnalyticsPreference)
        mockSessionManager = MockSessionManager()
        mockNetworkClient = NetworkClient()
        urlOpener = MockURLOpener()
        sut = SettingsCoordinator(analyticsCenter: mockAnalyticsCenter,
                                  sessionManager: mockSessionManager,
                                  networkClient: mockNetworkClient,
                                  urlOpener: urlOpener)
        window.rootViewController = sut.root
        window.makeKeyAndVisible()
    }
    
    override func tearDown() {
        window = nil
        mockAnalyticsService = nil
        mockAnalyticsPreference = nil
        mockAnalyticsCenter = nil
        mockSessionManager = nil
        mockNetworkClient = nil
        urlOpener = nil
        sut = nil
        
        WalletAvailabilityService.hasAccessedBefore = false
        
        super.tearDown()
    }
    
    func test_tabBarItem() {
        // WHEN the SettingsCoordinator has started
        sut.start()
        let settingsTab = UITabBarItem(title: "Settings",
                                      image: UIImage(systemName: "gearshape"),
                                      tag: 2)
        // THEN the bar button item of the root is correctly configured
        XCTAssertEqual(sut.root.tabBarItem.title, settingsTab.title)
        XCTAssertEqual(sut.root.tabBarItem.image, settingsTab.image)
        XCTAssertEqual(sut.root.tabBarItem.tag, settingsTab.tag)
    }
    
    func test_openSignOutPageWithWallet() throws {
        // WHEN Wallet has been accessed before
        WalletAvailabilityService.hasAccessedBefore = true
        // WHEN the SettingsCoordinator is started
        sut.start()
        // WHEN the openSignOutPage method is called
        sut.openSignOutPage()
        // THEN the presented view controller's view model is the WalletSignOutPageViewModel
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        let viewController = try XCTUnwrap(presentedVC.topViewController as? GDSInstructionsViewController)
        XCTAssertTrue(viewController.viewModel is WalletSignOutPageViewModel)
    }
    
    func test_openSignOutPageNoWallet() throws {
        // WHEN Wallet has not been accessed before
        WalletAvailabilityService.hasAccessedBefore = false
        // WHEN the SettingsCoordinator is started
        sut.start()
        // WHEN the openSignOutPage method is called
        sut.openSignOutPage()
        // THEN the presented view controller's view model is the SignOutPageViewModel
        let presentedVC = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        let viewController = try XCTUnwrap(presentedVC.topViewController as? GDSInstructionsViewController)
        XCTAssertTrue(viewController.viewModel is SignOutPageViewModel)
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
        sut.openDeveloperMenu()
        // THEN the presented view controller is the DeveloperMenuViewController
        let presentedViewController = try XCTUnwrap(sut.root.presentedViewController as? UINavigationController)
        XCTAssertTrue(presentedViewController.topViewController is DeveloperMenuViewController)
    }
}
