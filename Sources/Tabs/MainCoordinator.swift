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
                             TabCoordinator {
    private let windowManager: WindowManagement
    let root: UITabBarController
    var childCoordinators = [ChildCoordinator]()

    private var analyticsCenter: AnalyticsCentral
    private let sessionManager: SessionManager
    private let updateService: AppInformationProvider
    private let walletAvailabilityService: WalletFeatureAvailabilityService
    private let networkClient: NetworkClient
    
    private weak var loginCoordinator: LoginCoordinator?
    private weak var homeCoordinator: HomeCoordinator?
    private weak var walletCoordinator: WalletCoordinator?
    private weak var profileCoordinator: ProfileCoordinator?
    
    init(windowManager: WindowManagement,
         root: UITabBarController,
         analyticsCenter: AnalyticsCentral,
         networkClient: NetworkClient,
         sessionManager: SessionManager,
         updateService: AppInformationProvider = AppInformationService(baseURL: AppEnvironment.appInfoURL),
         walletAvailabilityService: WalletFeatureAvailabilityService = WalletAvailabilityService()) {
        self.windowManager = windowManager
        self.root = root
        self.analyticsCenter = analyticsCenter
        self.networkClient = networkClient
        self.sessionManager = sessionManager
        self.updateService = updateService
        self.walletAvailabilityService = walletAvailabilityService
    }
    
    func start() {
        root.delegate = self
        addTabs()
        fullLogin()
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(startReauth),
                         name: Notification.Name(.startReauth),
                         object: nil)
    }
    
    @objc private func startReauth() {
        fullLogin(loginError: TokenError.expired)
    }
    
    private func fullLogin(loginError: Error? = nil) {
        sessionManager.endCurrentSession()
        showLogin(loginError)
    }
    
    func handleUniversalLink(_ url: URL) {
        switch UniversalLinkQualifier.qualifyOneLoginUniversalLink(url) {
        case .login:
            loginCoordinator?.handleUniversalLink(url)
        case .wallet:
            if walletAvailabilityService.shouldShowFeatureOnUniversalLink {
                addWalletTab()
                walletCoordinator?.handleUniversalLink(url)
            }
        case .unknown:
            return
        }
    }
}

extension MainCoordinator {
    private func showLogin(_ loginError: Error?) {
        let lc = LoginCoordinator(appWindow: windowManager.appWindow,
                                  root: UINavigationController(),
                                  analyticsCenter: analyticsCenter,
                                  sessionManager: sessionManager,
                                  networkMonitor: NetworkMonitor.shared,
                                  loginError: loginError)
        openChildModally(lc, animated: false)
        loginCoordinator = lc
    }
    
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
        homeCoordinator = hc
    }
    
    private func addWalletTab() {
        let wc = WalletCoordinator(window: windowManager.appWindow,
                                   analyticsCenter: analyticsCenter,
                                   networkClient: networkClient,
                                   sessionManager: sessionManager)
        addTab(wc)
        root.viewControllers?.sort {
            $0.tabBarItem.tag < $1.tabBarItem.tag
        }
        walletCoordinator = wc
        walletAvailabilityService.hasAccessedPreviously()
    }
    
    private func addProfileTab() {
        let pc = ProfileCoordinator(analyticsService: analyticsCenter.analyticsService,
                                    urlOpener: UIApplication.shared)
        addTab(pc)
        profileCoordinator = pc
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
                analyticsCenter.analyticsPreferenceStore.hasAcceptedAnalytics = nil
                fullLogin()
                homeCoordinator?.baseVc?.isLoggedIn(false)
                root.selectedIndex = 0
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
