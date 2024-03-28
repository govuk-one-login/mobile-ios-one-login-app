import Coordination
import LocalAuthentication
import SecureStore
import UIKit

final class MainCoordinator: NSObject,
                             AnyCoordinator,
                             TabCoordinator {
    let window: UIWindow
    let root: UITabBarController
    let analyticsCenter: AnalyticsCentral
    var childCoordinators = [ChildCoordinator]()
    let userStore: UserStorable
    let tokenHolder = TokenHolder()
    private weak var loginCoordinator: LoginCoordinator?
    
    
    init(window: UIWindow,
         root: UITabBarController,
         analyticsCenter: AnalyticsCentral,
         userStore: UserStorable) {
        self.window = window
        self.root = root
        self.analyticsCenter = analyticsCenter
        self.userStore = userStore
        root.tabBar.backgroundColor = .systemBackground
        root.tabBar.tintColor = .gdsGreen
    }
    
    func start() {
        let lc = LoginCoordinator(window: window,
                                  root: UINavigationController(),
                                  analyticsCentre: analyticsCenter,
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
        guard let accessToken = tokenHolder.accessToken else { return }
        addHomeTab(accessToken: accessToken)
    }
    
    func addHomeTab(accessToken: String) {
        let homeCoordinator = HomeCoordinator(accessToken: accessToken)
        homeCoordinator.root.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        addTab(homeCoordinator)
    }
    
    func addWalletTab(accessToken: String) {
        let homeCoordinator = WalletCoordinator()
        homeCoordinator.root.tabBarItem = UITabBarItem(title: "Wallet", image: UIImage(systemName: "house"), tag: 0)
        addTab(homeCoordinator)
    }
    
    func addProfileTab(accessToken: String) {
        let homeCoordinator = ProfileCoordinator()
        homeCoordinator.root.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "house"), tag: 0)
        addTab(homeCoordinator)
    }
}

extension MainCoordinator: ParentCoordinator {
    func didRegainFocus(fromChild child: ChildCoordinator?) {
        switch child {
        case _ as LoginCoordinator:
            addTabs()
        default:
            break
        }
    }
}
