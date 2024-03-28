import Coordination
import UIKit

final class WalletCoordinator: NSObject,
                               AnyCoordinator,
                               ChildCoordinator,
                               NavigationCoordinator {
    var parentCoordinator: ParentCoordinator?
    var root = UINavigationController()
    
    override init() { }
    
    func start() {
        let vc = UIViewController()
        vc.navigationItem.hidesBackButton = true
        root.setViewControllers([vc], animated: true)
    }
}
