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
    func test_start_performsSetUpWithoutWallet() async {
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
        await sut.addTabTask?.value
        // THEN the TabManagerCoordinator should have child coordinators
        XCTAssertEqual(sut.childCoordinators.count, 2)
        XCTAssertTrue(sut.childCoordinators[0] is HomeCoordinator)
        XCTAssertTrue(sut.childCoordinators[1] is SettingsCoordinator)
    }
    
    @MainActor
    func test_start_performsSetUpWithWallet() async {
        // WHEN the wallet feature flag is on
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: true],
            featureFlags: [:]
        )
        // AND the TabManagerCoordinator is started
        sut.start()
        await sut.addTabTask?.value
        // THEN the TabManagerCoordinator should have child coordinators
        XCTAssertEqual(sut.childCoordinators.count, 3)
        XCTAssertTrue(sut.childCoordinators[0] is HomeCoordinator)
        XCTAssertTrue(sut.childCoordinators[1] is WalletCoordinator)
        XCTAssertTrue(sut.childCoordinators[2] is SettingsCoordinator)
    }
    
    @MainActor
    func test_handleUniversalLink() async throws {
        // GIVEN the wallet feature flag is on
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: true],
            featureFlags: [:]
        )
        sut.start()
        await sut.addTabTask?.value
        // WHEN the handleUniversalLink receives a deeplink
        let deeplink = try XCTUnwrap(URL(string: "google.co.uk/wallet"))
        await sut.handleUniversalLink(deeplink)
        // THEN the wallet tab should be added and the selected index should be 1
        XCTAssertTrue(sut.childCoordinators.contains(where: { $0 is WalletCoordinator }))
        XCTAssertTrue(sut.root.selectedIndex == 1)
    }
    
    @MainActor
    func test_tabSwitching() async throws {
        // GIVEN the wallet feature flag is on
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: true],
            featureFlags: [:]
        )
        sut.start()
        await sut.addTabTask?.value
        // start with home tab selected
        sut.root.selectedIndex = 0
        sut.updateSelectedTabIndex()
        XCTAssertEqual(sut.selectedTabIndex, 0)
        XCTAssertTrue(sut.isTabAlreadySelected())
        
        sut.root.selectedIndex = 1
        XCTAssertFalse(sut.isTabAlreadySelected())
    }
    
    @MainActor
    func test_callingStartTwiceDoesNotCreateTwoWalletTabs() async throws {
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: true],
            featureFlags: [:]
        )
        
        let containsWalletBeforeStart = sut.childCoordinators.contains { child in
            child is WalletCoordinator
        }
        
        // GIVEN child coordinators does not contain WalletCoordinator before start()
        XCTAssertFalse(containsWalletBeforeStart)
        
        // WHEN start is called once, there's 1 WalletCoordinator and 3 child coordinators in total
        sut.start()
        await sut.addTabTask?.value
        var walletCoordinators = sut.childCoordinators.filter { child in
            if child is WalletCoordinator {
                return true
            }
            return false
        }
        
        XCTAssertEqual(walletCoordinators.count, 1)
        XCTAssertEqual(sut.childCoordinators.count, 3)
        
        // AND start is called a second time
        sut.start()
        
        walletCoordinators = sut.childCoordinators.filter { child in
            if child is WalletCoordinator {
                return true
            }
            return false
        }
        
        // THEN WalletCoordinators in childCoordinators is still 1
        // AND child coordinators is still 3
        XCTAssertEqual(walletCoordinators.count, 1)
        XCTAssertEqual(sut.childCoordinators.count, 3)
    }
}
