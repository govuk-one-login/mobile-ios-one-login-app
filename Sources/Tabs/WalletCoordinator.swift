import Coordination
import UIKit

final class WalletCoordinator: NSObject,
                               AnyCoordinator,
                               ChildCoordinator,
                               NavigationCoordinator {
    var parentCoordinator: ParentCoordinator?
    let root = UINavigationController()
    
    func start() {
        let vc = UIViewController()
        root.setViewControllers([vc], animated: true)
    }
}
