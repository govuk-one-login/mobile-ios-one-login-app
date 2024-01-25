import Authentication
import Coordination
import Logging
import UIKit

@available(iOS 14.0, *)
final class MainCoordinator: NSObject,
                             ParentCoordinator,
                             NavigationCoordinator {
    let window: UIWindow
    let root: UINavigationController
    var childCoordinators = [ChildCoordinator]()
    
    init(window: UIWindow,
         root: UINavigationController) {
        self.window = window
        self.root = root
    }
    
    func start() {
        let appAttestViewController = AppAttestViewController()
        root.setViewControllers([appAttestViewController], animated: false)
    }
}
