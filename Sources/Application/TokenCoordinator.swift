import Authentication
import Coordination
import UIKit

final class TokenCoordinator: NSObject,
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
        let vc = TokensViewController(accessToken: accessToken)
        vc.navigationItem.hidesBackButton = true
        root.pushViewController(vc, animated: true)
    }
}
