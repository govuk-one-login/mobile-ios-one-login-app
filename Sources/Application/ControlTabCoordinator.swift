import Authentication
import Coordination
import UIKit

final class ControlTabCoordinator: NSObject,
                                   ChildCoordinator,
                                   NavigationCoordinator {
    let root: UINavigationController
    var parentCoordinator: ParentCoordinator?
    var childCoordinator: TabCoordinator?
    let accessToken: String
    
    init(root: UINavigationController,
         accessToken: String) {
        self.root = root
        self.accessToken = accessToken
    }
    
    func start() {
        let homeCoordinator = TabbingCoordinator(navRoot: root,
                                                 parentCoordinator: self,
                                                 accessToken: accessToken)
        childCoordinator = homeCoordinator
        homeCoordinator.start()
    }
}
