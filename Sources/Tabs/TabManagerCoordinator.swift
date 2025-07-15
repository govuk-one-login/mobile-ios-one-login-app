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
    private let networkClient: NetworkClient
    private let sessionManager: SessionManager
    
    lazy var delegate: TabCoordinatorDelegate? = TabCoordinatorDelegate(coordinator: self)
    
    var selectedTabIndex: Int?
    
    private var walletCoordinator: WalletCoordinator? {
        childCoordinators.firstInstanceOf(WalletCoordinator.self)
    }
    
    init(root: UITabBarController,
         analyticsService: OneLoginAnalyticsService,
         networkClient: NetworkClient,
         sessionManager: SessionManager) {
        self.root = root
        self.analyticsService = analyticsService
        self.networkClient = networkClient
        self.sessionManager = sessionManager
    }
    
    func start() {
        addTabs()
        subscribe()
    }
    
    func handleUniversalLink(_ url: URL) {
        guard WalletAvailabilityService.shouldShowFeatureOnUniversalLink else {
            return
        }
        if walletCoordinator == nil {
            addWalletTab()
        }
        root.selectedIndex = 1
        walletCoordinator?.handleUniversalLink(url)
    }
    
    private func addTabs() {
        addHomeTab()
        if WalletAvailabilityService.shouldShowFeature {
            addWalletTab()
        }
        addSettingsTab()
    }
    
    private func addHomeTab() {
        let hc = HomeCoordinator(analyticsService: analyticsService,
                                 networkClient: networkClient)
        addTab(hc)
    }
    
    private func addWalletTab() {
        let wc = WalletCoordinator(analyticsService: analyticsService,
                                   networkClient: networkClient,
                                   sessionManager: sessionManager)
        addTab(wc)
        root.viewControllers?.sort {
            $0.tabBarItem.tag < $1.tabBarItem.tag
        }
        WalletAvailabilityService.hasAccessedBefore = true
    }
    
    private func addSettingsTab() {
        let pc = SettingsCoordinator(analyticsService: analyticsService,
                                     sessionManager: sessionManager,
                                     networkClient: networkClient,
                                     urlOpener: UIApplication.shared)
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
            Task {
                do {
                    let isWalletAccessed = WalletAvailabilityService.hasAccessedBefore
                    try await sessionManager.clearAllSessionData(restartLoginFlow: false)
                    
                    let viewModel = SignOutSuccessfulViewModel(analyticsService: analyticsService,
                                                               withWallet: isWalletAccessed) {
                        NotificationCenter.default.post(name: .didLogout)
                    }
                    let signOutSuccessful = GDSInformationViewController(viewModel: viewModel)
                    signOutSuccessful.modalPresentationStyle = .fullScreen
                    root.present(signOutSuccessful, animated: false)
                } catch {
                    let viewModel = SignOutErrorViewModel(analyticsService: analyticsService,
                                                          error: error)
                    let signOutErrorScreen = GDSErrorScreen(viewModel: viewModel)
                    root.present(signOutErrorScreen, animated: true)
                }
            }
        }
    }
    
    private func subscribe() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidLogout),
                                               name: .didLogout)
    }
    
    @objc private func userDidLogout() {
        finish()
    }
}
