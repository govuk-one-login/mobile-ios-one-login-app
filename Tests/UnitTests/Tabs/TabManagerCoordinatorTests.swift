import GDSAnalytics
import GDSCommon
import Networking
@testable import OneLogin
import XCTest

final class TabManagerCoordinatorTests: XCTestCase {
    var tabBarController: UITabBarController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockSessionManager: MockSessionManager!
    var sut: TabManagerCoordinator!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        tabBarController = UITabBarController()
        mockAnalyticsService = MockAnalyticsService()
        mockSessionManager = MockSessionManager()
        sut = TabManagerCoordinator(root: tabBarController,
                                    analyticsService: mockAnalyticsService,
                                    networkClient: NetworkClient(),
                                    sessionManager: mockSessionManager)
    }
    
    override func tearDown() {
        tabBarController = nil
        mockAnalyticsService = nil
        mockSessionManager = nil
        sut = nil
        
        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [:]
        )
        
        super.tearDown()
    }
}

extension TabManagerCoordinatorTests {
    @MainActor
    func test_start_performsSetUpWithoutWallet() {
        // WHEN the Wallet the Feature Flag is off
        AppEnvironment.updateFlags(
            releaseFlags: [
                FeatureFlagsName.enableWalletVisibleViaDeepLink.rawValue: false,
                FeatureFlagsName.enableWalletVisibleIfExists.rawValue: false,
                FeatureFlagsName.enableWalletVisibleToAll.rawValue: false
            ],
            featureFlags: [:]
        )
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
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: true],
            featureFlags: [:]
        )
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
                                                      sessionManager: mockSessionManager,
                                                      networkClient: NetworkClient(),
                                                      urlOpener: MockURLOpener())
        // WHEN the TabManagerCoordinator's performChildCleanup method is called from SettingsCoordinator (on user sign out)
        sut.performChildCleanup(child: settingsCoordinator)
        // THEN a logout notification is sent
        await fulfillment(of: [exp], timeout: 5)
        // THEN the session should be cleared
        XCTAssertTrue(mockSessionManager.didCallClearAllSessionData)
    }
    
    @MainActor
    func test_performChildCleanup_fromSettingsCoordinator_errors() throws {
        let window = UIWindow()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        // GIVEN the app has an existing session
        mockSessionManager.errorFromClearAllSessionData = MockWalletError.cantDelete
        let settingsCoordinator = SettingsCoordinator(analyticsService: mockAnalyticsService,
                                                      sessionManager: mockSessionManager,
                                                      networkClient: NetworkClient(),
                                                      urlOpener: MockURLOpener())
        // WHEN the TabManagerCoordinator's performChildCleanup method is called from SettingsCoordinator (on user sign out)
        // but there was an error in signing out
        sut.performChildCleanup(child: settingsCoordinator)
        // THEN the sign out error screen should be presented
        waitForTruth(self.sut.root.presentedViewController is GDSErrorScreen, timeout: 5)
        XCTAssertTrue((sut.root.presentedViewController as? GDSErrorScreen)?.viewModel is SignOutErrorViewModel)
        // THEN the session should not be cleared
        XCTAssertFalse(mockSessionManager.didCallEndCurrentSession)
    }
    
    @MainActor
    func test_handleUniversalLink() throws {
        // GIVEN the wallet feature flag is on
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: true],
            featureFlags: [:]
        )
        sut.start()
        // WHEN the handleUniversalLink receives a deeplink
        let deeplink = try XCTUnwrap(URL(string: "google.co.uk/wallet"))
        sut.handleUniversalLink(deeplink)
        // THEN the wallet tab should be added and the selected index should be 1
        XCTAssertTrue(sut.childCoordinators.contains(where: { $0 is WalletCoordinator }))
        XCTAssertTrue(sut.root.selectedIndex == 1)
    }
    
    @MainActor
    func test_tabSwitching() throws {
        // GIVEN the wallet feature flag is on
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: true],
            featureFlags: [:]
        )
        sut.start()
        
        // start with home tab selected
        sut.root.selectedIndex = 0
        sut.updateSelectedTabIndex()
        XCTAssertEqual(sut.selectedTabIndex, 0)
        XCTAssertTrue(sut.isTabAlreadySelected())
        
        sut.root.selectedIndex = 1
        XCTAssertFalse(sut.isTabAlreadySelected())
    }
}
