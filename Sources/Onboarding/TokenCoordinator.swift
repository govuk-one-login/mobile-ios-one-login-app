import UIKit
import Coordination

final class TokenCoordinator: NSObject, ChildCoordinator, NavigationCoordinator {
    let root: UINavigationController
    var parentCoordinator: ParentCoordinator?

    init(root: UINavigationController) {
        self.root = root
    }

    func start() {
        let vc = TokensViewController()
        self.root.pushViewController(vc, animated: true)
    }
    

}
