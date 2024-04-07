import Coordination
import UIKit

final class ProfileCoordinator: NSObject,
                                AnyCoordinator,
                                ChildCoordinator,
                                NavigationCoordinator {
    var parentCoordinator: ParentCoordinator?
    var root = UINavigationController()
    
    override init() {
        root.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 2)
    }
    
    func start() {
        let vc = UIViewController()
        root.setViewControllers([vc], animated: true)
    }
}
