import Coordination
import Networking
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
    var networkClient: NetworkClient?
    private weak var loginCoordinator: LoginCoordinator?
    private weak var homeCoordinator: HomeCoordinator?
    
    init(windowManager: WindowManagement,
         root: UITabBarController,
         analyticsCenter: AnalyticsCentral,
         userStore: UserStorable) {
        self.windowManager = windowManager
        self.root = root
        self.analyticsCenter = analyticsCenter
        self.userStore = userStore
        root.tabBar.backgroundColor = .systemBackground
        root.tabBar.tintColor = .gdsGreen
    }
    
    func start() {
        addTabs()
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
        loginCoordinator?.handleUniversalLink(url)
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
    func addTabs() {
        addHomeTab()
        addWalletTab()
        addProfileTab()
    }
    
    func addHomeTab() {
        let hc = HomeCoordinator()
        hc.root.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        addTab(hc)
        homeCoordinator = hc
    }
    
    func addWalletTab() {
        let wc = WalletCoordinator()
        wc.root.tabBarItem = UITabBarItem(title: "Wallet", image: UIImage(systemName: "wallet.pass"), tag: 1)
        addTab(wc)
    }
    
    func addProfileTab() {
        let pc = ProfileCoordinator()
        pc.root.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 2)
        addTab(pc)
    }
}

extension MainCoordinator: ParentCoordinator {
    func didRegainFocus(fromChild child: ChildCoordinator?) {
        switch child {
        case _ as LoginCoordinator:
            homeCoordinator?.updateToken(accessToken: tokenHolder.accessToken)
            networkClient = NetworkClient(authenticationProvider: tokenHolder.tokenResponse)
        default:
            break
        }
    }
}
