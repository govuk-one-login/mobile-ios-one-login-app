import GDSAnalytics
import GDSCommon
import MobilePlatformServices
import Networking
@testable import OneLogin
import SecureStore
import XCTest

final class TabManagerCoordinatorTests: XCTestCase {
    var window: UIWindow!
    var tabBarController: UITabBarController!
    var mockAnalyticsService: MockAnalyticsService!
    var mockAnalyticsPreferenceStore: MockAnalyticsPreferenceStore!
    var mockAnalyticsCenter: MockAnalyticsCenter!
    var mockSessionManager: MockSessionManager!
    var mockUpdateService: MockAppInformationService!
    var mockWalletAvailabilityService: MockWalletAvailabilityService!
    var mockLocalAuthManager: MockLocalAuthManager!
    var sut: TabManagerCoordinator!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        tabBarController = .init()
        mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
        mockAnalyticsCenter = MockAnalyticsCenter(analyticsService: mockAnalyticsService,
                                                  analyticsPreferenceStore: mockAnalyticsPreferenceStore)
        mockSessionManager = MockSessionManager()
        mockUpdateService = MockAppInformationService()
        mockWalletAvailabilityService = MockWalletAvailabilityService()
        
        window = UIWindow()
        
        sut = TabManagerCoordinator(appWindow: window,
                                    root: tabBarController,
                                    analyticsCenter: mockAnalyticsCenter,
                                    networkClient: NetworkClient(),
                                    sessionManager: mockSessionManager,
                                    walletAvailabilityService: mockWalletAvailabilityService)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    override func tearDown() {
        window = nil
        tabBarController = nil
        mockAnalyticsService = nil
        mockAnalyticsPreferenceStore = nil
        mockAnalyticsCenter = nil
        mockSessionManager = nil
        mockUpdateService = nil
        mockWalletAvailabilityService = nil
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
        mockWalletAvailabilityService.shouldShowFeature = false
        
        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [:]
        )

        // AND the TabManagerCoordinator is started
        sut.start()
        // THEN the TabManagerCoordinator should have child coordinators
        XCTAssertEqual(sut.childCoordinators.count, 2)
        XCTAssertTrue(sut.childCoordinators[0] is HomeCoordinator)
        XCTAssertTrue(sut.childCoordinators[1] is ProfileCoordinator)
        // AND the root's delegate is the TabManagerCoordinator
        XCTAssertTrue(sut.root.delegate === sut)
    }
    
    @MainActor
    func test_start_performsSetUpWithWallet() {
        // WHEN the wallet feature flag is on
        mockWalletAvailabilityService.shouldShowFeature = true
        // AND the TabManagerCoordinator is started
        sut.start()
        // THEN the TabManagerCoordinator should have child coordinators
        XCTAssertEqual(sut.childCoordinators.count, 3)
        XCTAssertTrue(sut.childCoordinators[0] is HomeCoordinator)
        XCTAssertTrue(sut.childCoordinators[1] is WalletCoordinator)
        XCTAssertTrue(sut.childCoordinators[2] is ProfileCoordinator)
        // THEN the root's delegate is the TabManagerCoordinator
        XCTAssertTrue(sut.root.delegate === sut)
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
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, AppTaxonomy.login.rawValue)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "undefined")
    }
    
    @MainActor
    func test_didSelect_tabBarItem_wallet() {
        // GIVEN the wallet feature flag is on
        mockWalletAvailabilityService.shouldShowFeature = true
        
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
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, AppTaxonomy.login.rawValue)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "undefined")
    }
    
    @MainActor
    func test_didSelect_tabBarItem_profile() {
        mockWalletAvailabilityService.shouldShowFeature = false
        
        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [:]
        )
        
        // GIVEN the TabManagerCoordinator has started and added it's tab bar items
        sut.start()
        guard let profileVC = tabBarController.viewControllers?[1] else {
            XCTFail("ProfileVC not added as child viewcontroller to tabBarController")
            return
        }
        // WHEN the tab bar controller's delegate method didSelect is called with the profile view controller
        tabBarController.delegate?.tabBarController?(tabBarController, didSelect: profileVC)
        // THEN the profile view controller's tab bar event is sent
        let iconEvent = IconEvent(textKey: "profile")
        XCTAssertEqual(mockAnalyticsService.eventsLogged, [iconEvent.name.name])
        XCTAssertEqual(mockAnalyticsService.eventsParamsLogged, iconEvent.parameters)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level2"] as? String, AppTaxonomy.login.rawValue)
        XCTAssertEqual(mockAnalyticsService.additionalParameters["taxonomy_level3"] as? String, "undefined")
    }
    
    @MainActor
    func test_didRegainFocus_fromLoginCoordinator_withBearerToken() throws {
        // GIVEN the user has an active session
        let loginCoordinator = LoginCoordinator(appWindow: window,
                                                root: UINavigationController(),
                                                analyticsCenter: mockAnalyticsCenter,
                                                sessionManager: mockSessionManager,
                                                networkMonitor: MockNetworkMonitor(),
                                                isExpiredUser: true)
        // WHEN the TabManagerCoordinator didRegainFocus from the LoginCoordinator
        sut.didRegainFocus(fromChild: loginCoordinator)
        // THEN no coordinator should be launched
        XCTAssertEqual(sut.childCoordinators.count, 0)
    }
    
    @MainActor
    func test_performChildCleanup_fromProfileCoordinator_succeeds() async throws {
        let exp = XCTNSNotificationExpectation(
            name: .didLogout,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        // GIVEN the app has token information stored, the user has accepted analytics and the accessToken is valid
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        try mockSessionManager.setupSession(returningUser: true)
        let profileCoordinator = ProfileCoordinator(analyticsService: mockAnalyticsService,
                                                    sessionManager: mockSessionManager,
                                                    networkClient: NetworkClient(),
                                                    urlOpener: MockURLOpener(),
                                                    walletAvailabilityService: mockWalletAvailabilityService,
                                                    analyticsCenter: mockAnalyticsCenter)
        // WHEN the TabManagerCoordinator's performChildCleanup method is called from ProfileCoordinator (on user sign out)
        sut.performChildCleanup(child: profileCoordinator)
        // THEN a logout notification is sent
        await fulfillment(of: [exp], timeout: 5)
        // And the session should be cleared
        XCTAssertTrue(mockSessionManager.didCallClearAllSessionData)
    }
    
    @MainActor
    func test_performChildCleanup_fromProfileCoordinator_errors() throws {
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableSignoutError.rawValue: true],
            featureFlags: [:]
        )

        // GIVEN the app has token information store, the user has accepted analytics and the accessToken is valid
        mockAnalyticsPreferenceStore.hasAcceptedAnalytics = true
        try mockSessionManager.setupSession(returningUser: true)
        let profileCoordinator = ProfileCoordinator(analyticsService: mockAnalyticsService,
                                                    sessionManager: mockSessionManager,
                                                    networkClient: NetworkClient(),
                                                    urlOpener: MockURLOpener(),
                                                    walletAvailabilityService: mockWalletAvailabilityService,
                                                    analyticsCenter: mockAnalyticsCenter)
        // WHEN the TabManagerCoordinator's performChildCleanup method is called from ProfileCoordinator (on user sign out)
        // but there was an error in signing out
        sut.performChildCleanup(child: profileCoordinator)
        // THEN the sign out error screen should be presented
        let errorVC = try XCTUnwrap(sut.root.presentedViewController as? GDSErrorViewController)
        XCTAssertTrue(errorVC.viewModel is SignOutErrorViewModel)
        // THEN the tokens shouldn't be deleted and the analytics shouldn't be reset; the app shouldn't be reset
        XCTAssertFalse(mockSessionManager.didCallEndCurrentSession)
        XCTAssertTrue(mockAnalyticsPreferenceStore.hasAcceptedAnalytics == true)
    }
}
