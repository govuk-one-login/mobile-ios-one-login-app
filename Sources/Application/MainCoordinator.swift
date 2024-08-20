import Coordination
import GDSAnalytics
import LocalAuthentication
import Logging
import SecureStore
import UIKit

final class MainCoordinator: NSObject,
                             AnyCoordinator,
                             TabCoordinator {
    let root: UITabBarController
    var windowManager: WindowManagement
    var childCoordinators = [ChildCoordinator]()
    private var analyticsCenter: AnalyticsCentral
    private let userStore: UserStorable
    private let tokenVerifier: TokenVerifier
    
    private weak var qualifyingCoordinator: QualifyingCoordinator?
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
        showQualifyingCoordinator()
        root.delegate = self
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(startReauth),
                         name: Notification.Name(.startReauth),
                         object: nil)
    }

    func showQualifyingCoordinator() {
        let qc = QualifyingCoordinator(userStore: userStore,
                                       analyticsCenter: analyticsCenter)
        openChildModally(qc, animated: false)
        qualifyingCoordinator = qc
    }

    func evaluateRevisit(idToken: String? = nil) {
        if let idToken = idToken {
            do {
                TokenHolder.shared.idTokenPayload = try tokenVerifier.extractPayload(idToken)
                updateToken()
                fullLogin()
            } catch {
                handleLoginError(error)
            }
        } else {
            fullLogin(loginError: TokenError.expired)
        }
    }

    @objc private func startReauth() {
        fullLogin(loginError: TokenError.expired)
    }
    
    private func handleLoginError(_ error: Error) {
        switch error {
        case is JWTVerifierError,
            SecureStoreError.unableToRetrieveFromUserDefaults,
            SecureStoreError.cantInitialiseData,
            SecureStoreError.cantRetrieveKey:
            fullLogin(loginError: error)
        default:
            print("Token retrival error: \(error)")
        }
    }
    
    private func fullLogin(loginError: Error? = nil) {
        TokenHolder.shared.clearTokenHolder()
        userStore.clearTokens()
        if loginError as? TokenError != .expired {
            userStore.refreshStorage(accessControlLevel: nil)
        }
        showLogin(loginError)
        windowManager.hideUnlockWindow()
    }
    
    func handleUniversalLink(_ url: URL) {
        switch UniversalLinkQualifier.qualifyOneLoginUniversalLink(url) {
        case .login:
            loginCoordinator?.handleUniversalLink(url)
        case .wallet:
            walletCoordinator?.handleUniversalLink(url)
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
                                  userStore: userStore,
                                  networkMonitor: NetworkMonitor.shared,
                                  loginError: loginError)
        openChildModally(lc, animated: false)
        loginCoordinator = lc
    }
    
    private func addTabs() {
        if root.tabBar.items?.count == 0 {
            addHomeTab()
            addWalletTab()
            addProfileTab()
        }
    }
    
    private func addHomeTab() {
        let hc = HomeCoordinator(analyticsService: analyticsCenter.analyticsService,
                                 userStore: userStore)
        addTab(hc)
        homeCoordinator = hc
    }
    
    private func addWalletTab() {
        let wc = WalletCoordinator(window: windowManager.appWindow,
                                   analyticsCenter: analyticsCenter,
                                   userStore: userStore)
        addTab(wc)
        walletCoordinator = wc
    }
    
    private func addProfileTab() {
        let pc = ProfileCoordinator(analyticsService: analyticsCenter.analyticsService,
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
        switch child {
        case _ as LoginCoordinator:
            addTabs()
            updateToken()
        case let child as QualifyingCoordinator:
            guard let idToken = child.idToken else {
                child.root.dismiss(animated: true) {
                    self.fullLogin()
                }
                return
            }
            do {
                TokenHolder.shared.idTokenPayload = try tokenVerifier.extractPayload(idToken)
                evaluateRevisit(idToken: idToken)
                addTabs()
                updateToken()
                child.root.dismiss(animated: true)
            } catch {
                handleLoginError(error)
            }
        default:
            break
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
                userStore.resetPersistentSession()
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
