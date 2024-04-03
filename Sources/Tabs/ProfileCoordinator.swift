import Coordination
import UIKit

final class ProfileCoordinator: NSObject,
                                AnyCoordinator,
                                ChildCoordinator,
                                NavigationCoordinator {
    var parentCoordinator: ParentCoordinator?
    var root = UINavigationController()
    
    func start() {
        let vc = UIViewController()
        root.setViewControllers([vc], animated: true)
    }
}
