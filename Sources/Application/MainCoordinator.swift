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
    let tokenHolder = TokenHolder()
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
        showLogin()
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
    
    func evaluateRevisit(action: @escaping () -> Void) {
        Task {
            await MainActor.run {
                if userStore.returningAuthenticatedUser {
                    do {
                        let idToken = try userStore.secureStoreService.readItem(itemName: .idToken)
                        tokenHolder.idTokenPayload = try tokenVerifier.extractPayload(idToken)
                        if let loginCoordinator {
                            childDidFinish(loginCoordinator)
                        }
                        action()
                    } catch {
                        handleLoginError(error, action: action)
                    }
                } else {
                    tokenHolder.clearTokenHolder()
                    userStore.refreshStorage(accessControlLevel: LAContext().isPasscodeOnly ? .anyBiometricsOrPasscode : .currentBiometricsOrPasscode)
                    showLogin()
                    action()
                }
            }
        }
    }
    
    private func handleLoginError(_ error: Error, action: () -> Void) {
        switch error {
        case is JWTVerifierError,
            SecureStoreError.unableToRetrieveFromUserDefaults,
            SecureStoreError.cantInitialiseData,
            SecureStoreError.cantRetrieveKey:
            loginCoordinator?.tokenReadError = error
            refreshLogin(error, action: action)
        default:
            print("Token retrival error: \(error)")
        }
    }
    
    private func refreshLogin(_ error: Error, action: () -> Void) {
        if let loginCoordinator {
            childDidFinish(loginCoordinator)
        }
        tokenHolder.clearTokenHolder()
        userStore.refreshStorage(accessControlLevel: LAContext().isPasscodeOnly ? .anyBiometricsOrPasscode : .currentBiometricsOrPasscode)
        showLogin(error)
        action()
    }
    
    private func showLogin(_ error: Error? = nil) {
        let lc = LoginCoordinator(windowManager: windowManager,
                                  root: UINavigationController(),
                                  analyticsCenter: analyticsCenter,
                                  userStore: userStore,
                                  networkMonitor: NetworkMonitor.shared,
                                  tokenHolder: tokenHolder)
        lc.tokenReadError = error
        openChildModally(lc, animated: false)
        loginCoordinator = lc
    }
}

extension MainCoordinator {
    private func addTabs() {
        addHomeTab()
        addWalletTab()
        addProfileTab()
    }
    
    private func addHomeTab() {
        let hc = HomeCoordinator(analyticsService: analyticsCenter.analyticsService,
                                 userStore: userStore,
                                 tokenHolder: tokenHolder)
        addTab(hc)
        homeCoordinator = hc
    }
    
    private func addWalletTab() {
        let wc = WalletCoordinator(window: windowManager.appWindow,
                                   analyticsService: analyticsCenter.analyticsService,
                                   secureStoreService: userStore.secureStoreService,
                                   tokenHolder: tokenHolder)
        addTab(wc)
        walletCoordinator = wc
    }
    
    private func addProfileTab() {
        let pc = ProfileCoordinator(analyticsCenter: analyticsCenter,
                                    userStore: userStore,
                                    tokenHolder: tokenHolder,
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
        case let child as LoginCoordinator:
            if child.tokenReadError == nil {
                updateToken()
            }
        case _ as ProfileCoordinator:
            showLogin()
            homeCoordinator?.baseVc?.isLoggedIn(false)
            root.selectedIndex = 0
        default:
            break
        }
    }
    
    func performChildCleanup(child: ChildCoordinator) {
        if let child = child as? LoginCoordinator {
            child.root.dismiss(animated: false)
        }
    }
}
