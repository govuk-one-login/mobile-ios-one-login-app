import Coordination
import GDSAnalytics
import LocalAuthentication
import Logging
import SecureStore
import UIKit

final class MainCoordinator: NSObject,
                             AnyCoordinator,
                             TabCoordinator {
    private let windowManager: WindowManagement
    let root: UITabBarController
    var childCoordinators = [ChildCoordinator]()
    private var analyticsCenter: AnalyticsCentral
    private let userStore: UserStorable
    private let tokenVerifier: TokenVerifier
    private let updateService: AppInformationServicing
    
    private weak var loginCoordinator: LoginCoordinator?
    private weak var homeCoordinator: HomeCoordinator?
    private weak var walletCoordinator: WalletCoordinator?
    private weak var profileCoordinator: ProfileCoordinator?
    
    init(windowManager: WindowManagement,
         root: UITabBarController,
         analyticsCenter: AnalyticsCentral,
         userStore: UserStorable,
         tokenVerifier: TokenVerifier = JWTVerifier(),
         updateService: AppInformationServicing = AppInformationService()) {
        self.windowManager = windowManager
        self.root = root
        self.analyticsCenter = analyticsCenter
        self.userStore = userStore
        self.tokenVerifier = tokenVerifier
        self.updateService = updateService
    }
    
    func start() {
        addTabs()
        windowManager.displayUnlockWindow(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
            evaluateRevisit()
        }
        evaluateRevisit()
        root.delegate = self
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
                fullLogin(loginError: TokenError.expired)
            }
        } else {
            fullLogin()
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
    
    func checkAppVersion() {
        Task {
            do {
                let appInfo = try await updateService.fetchAppInfo()
                
                guard updateService.currentVersion >= appInfo.minimumVersion else {
                    return // TODO: DCMAW-9866 - Present 'app update required' screen
                }
                
            } catch {
                let error = ErrorPresenter
                    .createGenericError(errorDescription: error.localizedDescription,
                                        analyticsService: analyticsCenter.analyticsService) {
                        exit(0)
                    }
                root.present(error, animated: true)
            }
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
        addHomeTab()
        addWalletTab()
        addProfileTab()
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
