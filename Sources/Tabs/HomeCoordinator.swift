import Coordination
import UIKit

final class HomeCoordinator: NSObject,
                             AnyCoordinator,
                             ChildCoordinator,
                             NavigationCoordinator {
    var parentCoordinator: ParentCoordinator?
    var root = UINavigationController()
    private var accessToken: String?
    private let baseVc = TokensViewController()

    func start() {
        root.setViewControllers([baseVc], animated: true)
    }
    
    func updateToken(accessToken: String?) {
        baseVc.updateToken(accessToken: accessToken)
    }
}
