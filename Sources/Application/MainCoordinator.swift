import Coordination
import GDSAnalytics
import SecureStore
import UIKit

final class MainCoordinator: NSObject,
                             AnyCoordinator,
                             TabCoordinator {
    let windowManager: WindowManagement
    let root: UITabBarController
    var analyticsCenter: AnalyticsCentral
    var childCoordinators = [ChildCoordinator]()
    let userStore: UserStorable
    let tokenHolder = TokenHolder()
    private weak var loginCoordinator: LoginCoordinator?
    private weak var homeCoordinator: HomeCoordinator?
    private weak var profileCoordinator: ProfileCoordinator?
    private var tokenVerifier: TokenVerifier
    
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
        loginCoordinator?.handleUniversalLink(url)
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
                    tokenHolder.accessToken = nil
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
        tokenHolder.accessToken = nil
        // Should we be calling
        // userStore.refreshStorage(accessControlLevel: LAContext().isPasscodeOnly ? .anyBiometricsOrPasscode : .currentBiometricsOrPasscode)
        // instead here? vvv
        userStore.clearTokenInfo()
        showLogin(error)
        action()
    }
    
    private func showLogin(_ error: Error? = nil) {
        let lc = LoginCoordinator(windowManager: windowManager,
                                  root: UINavigationController(),
                                  analyticsCenter: analyticsCenter,
                                  networkMonitor: NetworkMonitor.shared,
                                  userStore: userStore,
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
                                 userStore: userStore)
        addTab(hc)
        homeCoordinator = hc
    }
    
    private func addWalletTab() {
        let wc = WalletCoordinator()
        addTab(wc)
    }
    
    private func addProfileTab() {
        let pc = ProfileCoordinator(analyticsCenter: analyticsCenter,
                                    urlOpener: UIApplication.shared,
                                    userStore: userStore)
        addTab(pc)
        profileCoordinator = pc
    }
    
    private func updateToken() {
        homeCoordinator?.updateToken(tokenHolder)
        profileCoordinator?.updateToken(tokenHolder)
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
