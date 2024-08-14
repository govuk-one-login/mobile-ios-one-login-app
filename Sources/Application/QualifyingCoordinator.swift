import Coordination
import UIKit

final class QualifyingCoordinator: NSObject,
                                   AnyCoordinator,
                                   NavigationCoordinator,
                                   ChildCoordinator {
    let root: UINavigationController
    weak var parentCoordinator: ParentCoordinator?
    var childCoordinators = [ChildCoordinator]()
    
    init(root: UINavigationController) {
        self.root = root
    }

    func start() {
        //Call to `/appInfo`
    }
    

}
