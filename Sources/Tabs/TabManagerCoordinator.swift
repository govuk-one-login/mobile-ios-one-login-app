import Coordination
import GDSAnalytics
import GDSCommon
import LocalAuthentication
import Logging
import MobilePlatformServices
import Networking
import SecureStore
import UIKit

/// A type that is responsible for coordinating the main functionality of the app, a tab bar navigation.
///
/// Performs management of the three tabs in the tab bar navigation:
/// - HomeCoordinator: the landing tab of the app where service cards are available.
/// - WalletCoordinator: hosting the wallet functionality.
/// - ProfileCoordinator: linking out to related services and meta app functionality like sign out.
///
@MainActor
final class TabManagerCoordinator: NSObject,
                                   AnyCoordinator,
                                   TabCoordinator,
                                   ChildCoordinator {
    private let appWindow: UIWindow
    let root: UITabBarController
    weak var parentCoordinator: ParentCoordinator?
    var childCoordinators = [ChildCoordinator]()
    private var analyticsCenter: AnalyticsCentral
    private let networkClient: NetworkClient
    private let sessionManager: SessionManager
    private let walletAvailabilityService: WalletFeatureAvailabilityService
    
    private var homeCoordinator: HomeCoordinator? {
        childCoordinators.firstInstanceOf(HomeCoordinator.self)
    }
    
    private var walletCoordinator: WalletCoordinator? {
        childCoordinators.firstInstanceOf(WalletCoordinator.self)
    }
    
    private var profileCoordinator: ProfileCoordinator? {
        childCoordinators.firstInstanceOf(ProfileCoordinator.self)
    }
    
    init(appWindow: UIWindow,
         root: UITabBarController,
         analyticsCenter: AnalyticsCentral,
         networkClient: NetworkClient,
         sessionManager: SessionManager,
         walletAvailabilityService: WalletFeatureAvailabilityService) {
        self.appWindow = appWindow
        self.root = root
        self.analyticsCenter = analyticsCenter
        self.networkClient = networkClient
        self.sessionManager = sessionManager
        self.walletAvailabilityService = walletAvailabilityService
    }
    
    func start() {
        root.delegate = self
        addTabs()
        subscribe()
    }
    
    func handleUniversalLink(_ url: URL) {
        guard walletAvailabilityService.shouldShowFeatureOnUniversalLink else {
            return
        }
        if walletCoordinator == nil {
            addWalletTab()
        }
        walletCoordinator?.handleUniversalLink(url)
    }
}

extension TabManagerCoordinator {
    private func addTabs() {
        addHomeTab()
        if walletAvailabilityService.shouldShowFeature {
            addWalletTab()
        }
        addProfileTab()
    }
    
    private func addHomeTab() {
        let hc = HomeCoordinator(analyticsService: analyticsCenter.analyticsService)
        addTab(hc)
    }
    
    private func addWalletTab() {
        let wc = WalletCoordinator(window: appWindow,
                                   analyticsCenter: analyticsCenter,
                                   networkClient: networkClient,
                                   sessionManager: sessionManager)
        addTab(wc)
        root.viewControllers?.sort {
            $0.tabBarItem.tag < $1.tabBarItem.tag
        }
        walletAvailabilityService.hasAccessedBefore = true
    }
    
    private func addProfileTab() {
        let pc = ProfileCoordinator(analyticsService: analyticsCenter.analyticsService,
                                    sessionManager: sessionManager,
                                    networkClient: networkClient,
                                    urlOpener: UIApplication.shared,
                                    walletAvailabilityService: walletAvailabilityService)
        addTab(pc)
    }
}

extension TabManagerCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        var event: IconEvent? {
            switch viewController.tabBarItem.tag {
            case 0:
                .init(textKey: "app_homeTitle")
            case 1:
                .init(textKey: "app_walletTitle")
            case 2:
                .init(textKey: "app_profileTitle")
            default:
                nil
            }
        }
        if let event {
            analyticsCenter.analyticsService.setAdditionalParameters(appTaxonomy: .login)
            analyticsCenter.analyticsService.logEvent(event)
        }
    }
}

extension TabManagerCoordinator: ParentCoordinator {
    func performChildCleanup(child: ChildCoordinator) {
        if child is ProfileCoordinator {
            do {
                #if DEBUG
                if AppEnvironment.signoutErrorEnabled {
                    throw SecureStoreError.cantDeleteKey
                }
                #endif
                try sessionManager.clearAllSessionData()
            } catch {
                let viewModel = SignOutErrorViewModel(analyticsService: analyticsCenter.analyticsService,
                                                      error: error)
                let signOutErrorScreen = GDSErrorViewController(viewModel: viewModel)
                root.present(signOutErrorScreen, animated: true)
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
