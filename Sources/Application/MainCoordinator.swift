import Coordination
import SecureStore
import UIKit

final class MainCoordinator: NSObject,
                             AnyCoordinator,
                             TabCoordinator {
    let windowManager: WindowManagement
    let root: UITabBarController
    let analyticsCenter: AnalyticsCentral
    var childCoordinators = [ChildCoordinator]()
    let userStore: UserStorable
    let tokenHolder = TokenHolder()
    private weak var loginCoordinator: LoginCoordinator?
    private weak var homeCoordinator: HomeCoordinator?
    private weak var walletCoordinator: WalletCoordinator?
    
    init(windowManager: WindowManagement,
         root: UITabBarController,
         analyticsCenter: AnalyticsCentral,
         userStore: UserStorable) {
        self.windowManager = windowManager
        self.root = root
        self.analyticsCenter = analyticsCenter
        self.userStore = userStore
    }
    
    func start() {
        configureTabs()
        let lc = LoginCoordinator(windowManager: windowManager,
                                  root: UINavigationController(),
                                  analyticsCenter: analyticsCenter,
                                  networkMonitor: NetworkMonitor.shared,
                                  userStore: userStore,
                                  tokenHolder: tokenHolder)
        openChildModally(lc, animated: false)
        loginCoordinator = lc
    }
    
    func handleUniversalLink(_ url: URL) {
        let path = url.lastPathComponent
        if path == .redirect {
            loginCoordinator?.handleUniversalLink(url)
        } else if path == .wallet {
            walletCoordinator?.walletSDK.deeplink(with: url.absoluteString)
        }
    }
    
    func evaluateRevisit(action: () -> Void) {
        if userStore.returningAuthenticatedUser {
            do {
                tokenHolder.accessToken = try userStore.secureStoreService.readItem(itemName: .accessToken)
                homeCoordinator?.updateToken(accessToken: tokenHolder.accessToken)
                action()
            } catch {
                print("Error getting token: \(error)")
            }
        } else if tokenHolder.validAccessToken || tokenHolder.accessToken == nil {
            action()
        } else {
            tokenHolder.accessToken = nil
            start()
            action()
        }
    }
}

extension MainCoordinator {
    func configureTabs() {
        root.tabBar.backgroundColor = .systemBackground
        root.tabBar.tintColor = .gdsGreen
        addHomeTab()
        addWalletTab()
        addProfileTab()
    }
    
    func addHomeTab() {
        let hc = HomeCoordinator()
        addTab(hc)
        homeCoordinator = hc
    }
    
    func addWalletTab() {
        let wc = WalletCoordinator(window: windowManager.appWindow,
                                   analyticsService: analyticsCenter.analyticsService)
        addTab(wc)
    }
    
    func addProfileTab() {
        let pc = ProfileCoordinator()
        addTab(pc)
    }
}

extension MainCoordinator: ParentCoordinator {
    func didRegainFocus(fromChild child: ChildCoordinator?) {
        switch child {
        case _ as LoginCoordinator:
            homeCoordinator?.updateToken(accessToken: tokenHolder.accessToken)
        default:
            break
        }
    }
}
