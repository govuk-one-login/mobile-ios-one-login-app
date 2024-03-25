import Authentication
import Coordination
import UIKit

final class HomeCoordinator: NSObject,
                             ChildCoordinator,
                             NavigationCoordinator {
    let root: UINavigationController
    var parentCoordinator: ParentCoordinator?
    let accessToken: String
    
    init(root: UINavigationController,
         accessToken: String) {
        self.root = root
        self.accessToken = accessToken
    }
    
    func start() {
        let vc = HomeViewController(nibName: "Home", bundle: .main)
        vc.navigationItem.hidesBackButton = true
        root.pushViewController(vc, animated: true)
    }
}
