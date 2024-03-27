import Authentication
import Coordination
import UIKit

final class ControlTabCoordinator: NSObject,
                                   ChildCoordinator,
                                   NavigationCoordinator {
    let root: UINavigationController
    var parentCoordinator: ParentCoordinator?
    var childCoordinator: TabCoordinator?
    let analyticsCentre: AnalyticsCentral
    let accessToken: String
    
    init(root: UINavigationController,
         analyticsCentre: AnalyticsCentral,
         accessToken: String) {
        self.root = root
        self.analyticsCentre = analyticsCentre
        self.accessToken = accessToken
    }
    
    func start() {
        let homeCoordinator = TabbingCoordinator(navRoot: root,
                                                 parentCoordinator: self,
                                                 analyticsCentre: analyticsCentre,
                                                 accessToken: accessToken)
        childCoordinator = homeCoordinator
        homeCoordinator.start()
    }
}
