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
    
    override init() {
        root.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
    }

    func start() {
        root.setViewControllers([baseVc], animated: true)
    }
    
    func updateToken(accessToken: String?) {
        baseVc.updateToken(accessToken: accessToken)
    }
}
