import Coordination
import GDSAnalytics
import LocalAuthentication
import Logging
import MobilePlatformServices
import Networking
import SecureStore
import UIKit

final class MainCoordinator: NSObject,
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
        childCoordinators.first as? HomeCoordinator
    }

    private var walletCoordinator: WalletCoordinator? {
        childCoordinators.first as? WalletCoordinator
    }

    private var profileCoordinator: ProfileCoordinator? {
        childCoordinators.first as? ProfileCoordinator
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
    }
    
    func handleUniversalLink(_ url: URL) {
        if walletAvailabilityService.shouldShowFeatureOnUniversalLink {
            addWalletTab()
            walletCoordinator?.handleUniversalLink(url)
        }
    }
}

extension MainCoordinator {
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
        let pc = ProfileCoordinator(analyticsService: analyticsCenter.analyticsService,
                                    urlOpener: UIApplication.shared)
        addTab(pc)
    }
    
    private func updateToken() {
        if let user = sessionManager.user {
            homeCoordinator?.updateUser(user)
            profileCoordinator?.updateUser(user)
        }
    }
}

extension MainCoordinator: UITabBarControllerDelegate {
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

extension MainCoordinator: ParentCoordinator {
    func didRegainFocus(fromChild child: ChildCoordinator?) {
        if child is LoginCoordinator {
            updateToken()
        }
    }
    
    func performChildCleanup(child: ChildCoordinator) {
        if child is ProfileCoordinator {
            do {
                #if DEBUG
                if AppEnvironment.signoutErrorEnabled {
                    throw SecureStoreError.cantDeleteKey
                }
                #endif
                try walletCoordinator?.deleteWalletData()
                sessionManager.clearAllSessionData()
                analyticsCenter.resetAnalyticsPreferences()
                NotificationCenter.default
                    .post(name: Notification.Name(.logOut), object: nil)
            } catch {
                let signOutErrorScreen = ErrorPresenter
                    .createSignOutError(errorDescription: error.localizedDescription,
                                        analyticsService: analyticsCenter.analyticsService) {
                        exit(0)
                    }
                root.present(signOutErrorScreen, animated: true)
            }
        }
    }
}
