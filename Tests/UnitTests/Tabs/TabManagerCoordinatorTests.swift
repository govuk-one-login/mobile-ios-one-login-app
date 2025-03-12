import GDSAnalytics
import GDSCommon
import Networking
@testable import OneLogin
import XCTest

final class TabManagerCoordinatorTests: XCTestCase {
    var tabBarController: UITabBarController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockAnalyticsCenter: MockAnalyticsCenter!
    var mockSessionManager: MockSessionManager!
    var sut: TabManagerCoordinator!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        tabBarController = UITabBarController()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                  analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockSessionManager = MockSessionManager()
        sut = TabManagerCoordinator(root: tabBarController,
                                    analyticsCenter: mockAnalyticsCenter,
                                    networkClient: NetworkClient(),
                                    sessionManager: mockSessionManager)
    }
    
    override func tearDown() {
        tabBarController = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCenter = nil
        mockSessionManager = nil
        sut = nil
        
        UserDefaults.standard.removeObject(forKey: FeatureFlagsName.enableWalletVisibleToAll.rawValue)
        
        super.tearDown()
    }
}

extension TabManagerCoordinatorTests {
    @MainActor
    func test_start_performsSetUpWithoutWallet() {
        // WHEN the Wallet the Feature Flag is off
        UserDefaults.standard.removeObject(forKey: FeatureFlagsName.enableWalletVisibleToAll.rawValue)
        // AND the TabManagerCoordinator is started
        sut.start()
        // THEN the TabManagerCoordinator should have child coordinators
        XCTAssertEqual(sut.childCoordinators.count, 2)
        XCTAssertTrue(sut.childCoordinators[0] is HomeCoordinator)
        XCTAssertTrue(sut.childCoordinators[1] is SettingsCoordinator)
    }
    
    @MainActor
    func test_start_performsSetUpWithWallet() {
        // WHEN the wallet feature flag is on
        UserDefaults.standard.set(true, forKey: FeatureFlagsName.enableWalletVisibleToAll.rawValue)
        // AND the TabManagerCoordinator is started
        sut.start()
        // THEN the TabManagerCoordinator should have child coordinators
        XCTAssertEqual(sut.childCoordinators.count, 3)
        XCTAssertTrue(sut.childCoordinators[0] is HomeCoordinator)
        XCTAssertTrue(sut.childCoordinators[1] is WalletCoordinator)
        XCTAssertTrue(sut.childCoordinators[2] is SettingsCoordinator)
    }
    
    @MainActor
    func test_didSelect_tabBarItem_home() {
        // GIVEN the TabManagerCoordinator has started and added it's tab bar items
        sut.start()
        guard let homeVC = tabBarController.viewControllers?[0] else {
            XCTFail("HomeVC not added as child viewcontroller to tabBarController")
            return
        }
        // WHEN the tab bar controller's delegate method didSelect is called with the home view controller
        tabBarController.delegate?.tabBarController?(tabBarController, didSelect: homeVC)
        // THEN the home view controller's tab bar event is sent
        let iconEvent = IconEvent(textKey: "home")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [iconEvent.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["type"], iconEvent.type.rawValue)
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged["text"], iconEvent.text)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, AppTaxonomy.home.rawValue)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "undefined")
    }
    
    @MainActor
    func test_didSelect_tabBarItem_wallet() {
        // GIVEN the wallet feature flag is on
        UserDefaults.standard.set(true, forKey: FeatureFlagsName.enableWalletVisibleToAll.rawValue)
        // WHEN the TabManagerCoordinator has started and added it's tab bar items
        sut.start()
        guard let walletVC = tabBarController.viewControllers?[1] else {
            XCTFail("WalletVC not added as child viewcontroller to tabBarController")
            return
        }
        // AND the tab bar controller's delegate method didSelect is called with the wallet view controller
        tabBarController.delegate?.tabBarController?(tabBarController, didSelect: walletVC)
        // THEN the wallet view controller's tab bar event is sent
        let iconEvent = IconEvent(textKey: "wallet")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [iconEvent.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, iconEvent.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, AppTaxonomy.wallet.rawValue)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "undefined")
    }
    
    @MainActor
    func test_didSelect_tabBarItem_settings() {
        // GIVEN the TabManagerCoordinator has started and added it's tab bar items
        sut.start()
        guard let settingsVC = tabBarController.viewControllers?[1] else {
            XCTFail("SettingsVC not added as child viewcontroller to tabBarController")
            return
        }
        // WHEN the tab bar controller's delegate method didSelect is called with the settings view controller
        tabBarController.delegate?.tabBarController?(tabBarController, didSelect: settingsVC)
        // THEN the settings view controller's tab bar event is sent
        let iconEvent = IconEvent(textKey: "settings")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [iconEvent.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, iconEvent.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, AppTaxonomy.settings.rawValue)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "undefined")
    }
    
    @MainActor
    func test_performChildCleanup_fromSettingsCoordinator_succeeds() async throws {
        let exp = XCTNSNotificationExpectation(
            name: .didLogout,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        // GIVEN the app has an existing session
        let settingsCoordinator = SettingsCoordinator(analyticsCenter: MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                                                           analyticsPreferenceStore: mockAnalyticsPreferenceStore),
                                                      sessionManager: mockSessionManager,
                                                      networkClient: NetworkClient(),
                                                      urlOpener: MockURLOpener())
        // WHEN the TabManagerCoordinator's performChildCleanup method is called from SettingsCoordinator (on user sign out)
        sut.performChildCleanup(child: settingsCoordinator)
        // THEN the session should not be cleared
        XCTAssertTrue(mockSessionManager.didCallClearAllSessionData)
        // THEN a logout notification is sent
        await fulfillment(of: [exp], timeout: 5)
    }
    
    @MainActor
    func test_performChildCleanup_fromSettingsCoordinator_errors() throws {
        let window = UIWindow()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        // GIVEN the app has an existing session
        mockSessionManager.errorFromClearAllSessionData = MockWalletError.cantDelete
        let settingsCoordinator = SettingsCoordinator(analyticsCenter: MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                                                           analyticsPreferenceStore: mockAnalyticsPreferenceStore),
                                                      sessionManager: mockSessionManager,
                                                      networkClient: NetworkClient(),
                                                      urlOpener: MockURLOpener())
        // WHEN the TabManagerCoordinator's performChildCleanup method is called from SettingsCoordinator (on user sign out)
        // but there was an error in signing out
        sut.performChildCleanup(child: settingsCoordinator)
        // THEN the sign out error screen should be presented
        let errorVC = try XCTUnwrap(sut.root.presentedViewController as? GDSErrorViewController)
        XCTAssertTrue(errorVC.viewModel is SignOutErrorViewModel)
        // THEN the session should not be cleared
        XCTAssertFalse(mockSessionManager.didCallEndCurrentSession)
    }
    
    @MainActor
    func test_handleUniversalLink() throws {
        // GIVEN the wallet feature flag is on
        UserDefaults.standard.set(true, forKey: FeatureFlagsName.enableWalletVisibleToAll.rawValue)
        sut.start()
        // WHEN the handleUniversalLink receives a deeplink
        let deeplink = try XCTUnwrap(URL(string: "google.co.uk/wallet"))
        sut.handleUniversalLink(deeplink)
        // THEN the wallet tab should be added and the selected index should be 1
        XCTAssertTrue(sut.childCoordinators.contains(where: { $0 is WalletCoordinator }))
        XCTAssertTrue(sut.root.selectedIndex == 1)
    }
}
