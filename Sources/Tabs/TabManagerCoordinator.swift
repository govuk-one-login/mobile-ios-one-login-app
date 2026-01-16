import Coordination
import GDSCommon
import Logging
import Networking
import SecureStore
import UIKit

/// A type that is responsible for coordinating the main functionality of the app, a tab bar navigation.
///
/// Performs management of the three tabs in the tab bar navigation:
/// - HomeCoordinator: the landing tab of the app where service cards are available.
/// - WalletCoordinator: hosting the wallet functionality.
/// - SettingsCoordinator: linking out to related services and meta app functionality like sign out.
///
@MainActor
final class TabManagerCoordinator: NSObject,
                                   AnyCoordinator,
                                   ChildCoordinator,
                                   TabCoordinatorV2 {
    let root: UITabBarController
    weak var parentCoordinator: ParentCoordinator?
    var childCoordinators = [ChildCoordinator]()
    private let analyticsService: OneLoginAnalyticsService
    private let networkingService: OneLoginNetworkingService
    private let sessionManager: SessionManager
    
    lazy var delegate: TabCoordinatorDelegate? = TabCoordinatorDelegate(coordinator: self)
    
    var selectedTabIndex: Int?
    
    private var walletCoordinator: WalletCoordinator? {
        childCoordinators.firstInstanceOf(WalletCoordinator.self)
    }
    
    private(set) var addTabTask: Task<Void, Never>?
    
    init(
        root: UITabBarController,
        analyticsService: OneLoginAnalyticsService,
        networkingService: OneLoginNetworkingService,
        sessionManager: SessionManager
    ) {
        self.root = root
        self.analyticsService = analyticsService
        self.networkingService = networkingService
        self.sessionManager = sessionManager
    }
    
    func start() {
        addTabs()
    }
    
    func handleUniversalLink(_ url: URL) async {
        await addTabTask?.value
        
        root.selectedIndex = 1
        walletCoordinator?.handleUniversalLink(url)
    }
    
    private func addTabs() {
        addTabTask = Task {
            addHomeTab()
            addWalletTab()
            addSettingsTab()
        }
    }
    
    private func addHomeTab() {
        guard childCoordinators.firstInstanceOf(HomeCoordinator.self) == nil else {
            return
        }
        
        let hc = HomeCoordinator(
            analyticsService: analyticsService,
            networkingService: networkingService
        )
        addTab(hc)
    }
    
    private func addWalletTab() {
        guard childCoordinators.firstInstanceOf(WalletCoordinator.self) == nil else {
            return
        }
        
        let wc = WalletCoordinator(
            analyticsService: analyticsService,
            networkingService: networkingService,
            sessionManager: sessionManager
        )
        addTab(wc)
        
        root.viewControllers?.sort {
            $0.tabBarItem.tag < $1.tabBarItem.tag
        }
    }
    
    private func addSettingsTab() {
        guard childCoordinators.firstInstanceOf(SettingsCoordinator.self) == nil else {
            return
        }
        
        let pc = SettingsCoordinator(
            analyticsService: analyticsService,
            sessionManager: sessionManager,
            networkingService: networkingService,
            urlOpener: UIApplication.shared
        )
        addTab(pc)
    }
    
    func updateSelectedTabIndex() {
        selectedTabIndex = root.selectedIndex
    }
    
    func isTabAlreadySelected() -> Bool {
        return selectedTabIndex == root.selectedIndex
    }
}

extension TabManagerCoordinator: ParentCoordinator {
    func performChildCleanup(child: ChildCoordinator) {
        if child is SettingsCoordinator {
            NotificationCenter.default.post(name: .userDidLogout)
            finish()
        }
    }
}
