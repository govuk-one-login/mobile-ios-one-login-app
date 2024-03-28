import Coordination
import UIKit

final class WalletCoordinator: NSObject,
                               AnyCoordinator,
                               ChildCoordinator,
                               NavigationCoordinator {
    var parentCoordinator: ParentCoordinator?
    var root = UINavigationController()
    let accessToken: String
    
    override init() { }
    
    func start() {
        let vc = UIViewController()
        vc.navigationItem.hidesBackButton = true
        root.setViewControllers([vc], animated: true)
    }
}
