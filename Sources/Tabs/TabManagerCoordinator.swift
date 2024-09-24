import Coordination
import GDSAnalytics
import GDSCommon
import LocalAuthentication
import Logging
import MobilePlatformServices
import Networking
import SecureStore
import UIKit

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
         walletAvailabilityService: WalletFeatureAvailabilityService = WalletAvailabilityService()) {
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
        addWalletTab()
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
        let hc = HomeCoordinator(analyticsService: analyticsCenter.analyticsService,
                                 networkClient: networkClient,
                                 sessionManager: sessionManager)
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
        walletAvailabilityService.hasAccessedPreviously()
    }
    
    private func addProfileTab() {
        let pc = ProfileCoordinator(userProvider: sessionManager,
                                    analyticsService: analyticsCenter.analyticsService,
                                    urlOpener: UIApplication.shared)
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
                let viewModel = SignOutErrorViewModel(errorDescription: error.localizedDescription,
                                                      analyticsService: analyticsCenter.analyticsService) {
                    fatalError("We were unable to resume the session, there's not much we can do to help the user")
                }
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
