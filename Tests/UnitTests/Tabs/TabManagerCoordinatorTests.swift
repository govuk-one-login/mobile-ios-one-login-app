import GDSAnalytics
import GDSCommon
import Networking
@testable import OneLogin
import XCTest

final class TabManagerCoordinatorTests: XCTestCase {
    var tabBarController: UITabBarController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockSessionManager: MockSessionManager!
    var sut: TabManagerCoordinator!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        tabBarController = UITabBarController()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockSessionManager = MockSessionManager()
        sut = TabManagerCoordinator(root: tabBarController,
                                    analyticsService: mockAnalyticsService,
                                    analyticsPreferenceStore: mockAnalyticsPreferenceStore,
                                    networkClient: NetworkClient(),
                                    sessionManager: mockSessionManager)
    }
    
    override func tearDown() {
        tabBarController = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
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
    func test_performChildCleanup_fromSettingsCoordinator_succeeds() async throws {
        let exp = XCTNSNotificationExpectation(
            name: .didLogout,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        // GIVEN the app has an existing session
        let settingsCoordinator = SettingsCoordinator(analyticsService: mockAnalyticsService,
                                                      analyticsPreferenceStore: mockAnalyticsPreferenceStore,
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
        let settingsCoordinator = SettingsCoordinator(analyticsService: mockAnalyticsService,
                                                      analyticsPreferenceStore: mockAnalyticsPreferenceStore,
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
