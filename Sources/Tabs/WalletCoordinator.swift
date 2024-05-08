import Coordination
import UIKit

final class WalletCoordinator: NSObject,
                               AnyCoordinator,
                               ChildCoordinator,
                               NavigationCoordinator {
    var parentCoordinator: ParentCoordinator?
    let root = UINavigationController()
    
    func start() {
        root.tabBarItem = UITabBarItem(title: "Wallet", image: UIImage(systemName: "wallet.pass"), tag: 1)
        let vc = UIViewController()
        root.setViewControllers([vc], animated: true)
    }
}
