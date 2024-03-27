import Coordination
import UIKit

final class ProfileCoordinator: NSObject,
                                AnyCoordinator,
                                ChildCoordinator,
                                NavigationCoordinator {
    var parentCoordinator: ParentCoordinator?
    var root = UINavigationController()
    
    override init() {
        root.navigationBar.isHidden = true
    }
    
    func start() { }
}
