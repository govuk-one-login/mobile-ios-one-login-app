import Coordination
import GDSAnalytics
import LocalAuthentication
import SecureStore
import UIKit

final class MainCoordinator: NSObject,
                             AnyCoordinator,
                             TabCoordinator {
    let windowManager: WindowManagement
    let root: UITabBarController
    var childCoordinators = [ChildCoordinator]()
    var analyticsCenter: AnalyticsCentral
    let userStore: UserStorable
    private var tokenVerifier: TokenVerifier
    
    private weak var loginCoordinator: LoginCoordinator?
    private weak var homeCoordinator: HomeCoordinator?
    private weak var walletCoordinator: WalletCoordinator?
    private weak var profileCoordinator: ProfileCoordinator?
    
    init(windowManager: WindowManagement,
         root: UITabBarController,
         analyticsCenter: AnalyticsCentral,
         userStore: UserStorable,
         tokenVerifier: TokenVerifier = JWTVerifier()) {
        self.windowManager = windowManager
        self.root = root
        self.analyticsCenter = analyticsCenter
        self.userStore = userStore
        self.tokenVerifier = tokenVerifier
    }
    
    func start() {
        root.delegate = self
        addTabs()
        windowManager.displayUnlockWindow(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
            evaluateRevisit()
        }
        evaluateRevisit()
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(startReauth),
                         name: Notification.Name(.startReauth),
                         object: nil)
    }
    
    func evaluateRevisit() {
        if userStore.previouslyAuthenticatedUser != nil {
            if userStore.validAuthenticatedUser {
                Task(priority: .userInitiated) {
                    await MainActor.run {
                        do {
                            let idToken = try userStore.readItem(itemName: .idToken,
                                                                 storage: .authenticated)
                            TokenHolder.shared.idTokenPayload = try tokenVerifier.extractPayload(idToken)
                            updateToken()
                            windowManager.hideUnlockWindow()
                        } catch {
                            handleLoginError(error)
                        }
                    }
                }
            } else {
                analyticsCenter.analyticsPreferenceStore.hasAcceptedAnalytics = nil
                fullLogin(error: TokenError.expired)
            }
        } else {
            fullLogin()
        }
    }
    
    @objc func startReauth() {
        fullLogin(reauth: true)
    }
    
    private func handleLoginError(_ error: Error) {
        switch error {
        case is JWTVerifierError,
            SecureStoreError.unableToRetrieveFromUserDefaults,
            SecureStoreError.cantInitialiseData,
            SecureStoreError.cantRetrieveKey:
            fullLogin(error: error)
        default:
            print("Token retrival error: \(error)")
        }
    }
    
    private func fullLogin(error: Error? = nil, reauth: Bool = false) {
        TokenHolder.shared.clearTokenHolder()
        userStore.refreshStorage(accessControlLevel: nil)
        showLogin(error, reauth: reauth)
        windowManager.hideUnlockWindow()
    }
    
    func handleUniversalLink(_ url: URL) {
        switch UniversalLinkQualifier.qualifyOneLoginUniversalLink(url) {
        case .login:
            loginCoordinator?.handleUniversalLink(url)
        case .wallet:
            walletCoordinator?.walletSDK.deeplink(with: url.absoluteString)
        case .unknown:
            return
        }
    }
}

extension MainCoordinator {
    private func showLogin(_ error: Error?, reauth: Bool) {
        let lc = LoginCoordinator(windowManager: windowManager,
                                  root: UINavigationController(),
                                  analyticsCenter: analyticsCenter,
                                  userStore: userStore,
                                  networkMonitor: NetworkMonitor.shared,
                                  reauth: reauth)
        lc.loginError = error
        openChildModally(lc, animated: false)
        loginCoordinator = lc
    }
    
    private func addTabs() {
        addHomeTab()
        addWalletTab()
        addProfileTab()
    }
    
    private func addHomeTab() {
        let hc = HomeCoordinator(window: windowManager.appWindow,
                                 analyticsService: analyticsCenter.analyticsService,
                                 userStore: userStore)
        addTab(hc)
        homeCoordinator = hc
    }
    
    private func addWalletTab() {
        let wc = WalletCoordinator(window: windowManager.appWindow,
                                   analyticsCenter: analyticsCenter,
                                   secureStoreService: userStore.openStore)
        addTab(wc)
        walletCoordinator = wc
    }
    
    private func addProfileTab() {
        let pc = ProfileCoordinator(analyticsService: analyticsCenter.analyticsService,
                                    userStore: userStore,
                                    urlOpener: UIApplication.shared)
        addTab(pc)
        profileCoordinator = pc
    }
    
    private func updateToken() {
        homeCoordinator?.updateToken()
        walletCoordinator?.updateToken()
        profileCoordinator?.updateToken()
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
        switch child {
        case _ as HomeCoordinator:
            updateToken()
        case _ as ProfileCoordinator:
            do {
                #if DEBUG
                if AppEnvironment.signoutErrorEnabled {
                    throw SecureStoreError.cantDeleteKey
                }
                #endif
                try walletCoordinator?.deleteWalletData()
                userStore.removePersistentSessionId()
                userStore.defaultsStore.set(nil, forKey: "returningUser")
                analyticsCenter.analyticsPreferenceStore.hasAcceptedAnalytics = nil
                fullLogin()
                homeCoordinator?.baseVc?.isLoggedIn(false)
                root.selectedIndex = 0
            } catch {
                let navController = UINavigationController()
                let signOutErrorScreen = ErrorPresenter
                    .createSignOutError(errorDescription: error.localizedDescription,
                                        analyticsService: analyticsCenter.analyticsService) {
                        exit(0)
                    }
                navController.setViewControllers([signOutErrorScreen], animated: false)
                root.present(navController, animated: true)
            }
        default:
            break
        }
    }
}
