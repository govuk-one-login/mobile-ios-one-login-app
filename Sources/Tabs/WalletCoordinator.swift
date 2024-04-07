import Coordination
import Logging
import UIKit
import Wallet

final class WalletCoordinator: NSObject,
                               AnyCoordinator,
                               ChildCoordinator,
                               NavigationCoordinator {
    let window: UIWindow
    var parentCoordinator: ParentCoordinator?
    let root = UINavigationController()
    let analyticsService: AnalyticsService
    let walletSDK = WalletSDK()
    
    init(window: UIWindow, analyticsService: AnalyticsService) {
        self.window = window
        self.analyticsService = analyticsService
        root.tabBarItem = UITabBarItem(title: "Wallet", image: UIImage(systemName: "wallet.pass"), tag: 1)
    }
    
    func start() {
        walletSDK.start(in: window, with: root, analyticsService: analyticsService)
    }
}
