import Coordination
import UIKit

final class HomeCoordinator: NSObject,
                             AnyCoordinator,
                             ChildCoordinator,
                             NavigationCoordinator {
    var parentCoordinator: ParentCoordinator?
    var root = UINavigationController()
    let accessToken: String

    init(accessToken: String) {
        self.accessToken = accessToken
    }

    func start() {
        let vc = TokensViewController(accessToken: accessToken)
        vc.navigationItem.hidesBackButton = true
        root.setViewControllers([vc], animated: true)
    }
}
