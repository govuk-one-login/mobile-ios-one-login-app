import Coordination
import UIKit

final class TabbingCoordinator: NSObject,
                                AnyCoordinator,
                                TabCoordinator {
    let navRoot: UINavigationController
    var root: UITabBarController = UITabBarController()
    let parentCoordinator: NavigationCoordinator
    var childCoordinators = [ChildCoordinator]()
    let accessToken: String
    
    init(navRoot: UINavigationController,
         parentCoordinator: NavigationCoordinator,
         accessToken: String) {
        self.navRoot = navRoot
        self.parentCoordinator = parentCoordinator
        self.accessToken = accessToken
    }
    
    func start() {
        navRoot.pushViewController(root, animated: true)
        root.navigationItem.hidesBackButton = true
        root.tabBar.backgroundColor = .systemBackground
        addTabs()
    }
    
    func addTabs() {
        addHomeTab()
        addProfileTab()
    }
    
    func addHomeTab() {
        let homeCoordinator = HomeCoordinator(accessToken: accessToken)
        homeCoordinator.root.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        addTab(homeCoordinator)
    }
    
    func addProfileTab() {
        let profileCoordinator = ProfileCoordinator()
        profileCoordinator.root.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 1)
        addTab(profileCoordinator)
    }
}

extension TabbingCoordinator: ParentCoordinator {
    func didRegainFocus(fromChild child: ChildCoordinator?) { }
}
