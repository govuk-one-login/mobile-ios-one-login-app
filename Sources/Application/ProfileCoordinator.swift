import Coordination
import UIKit

final class ProfileCoordinator: NSObject,
                                AnyCoordinator,
                                ChildCoordinator,
                                NavigationCoordinator {
    var parentCoordinator: ParentCoordinator?
    var root = UINavigationController()
    let analyticsCentre: AnalyticsCentral
    
    init(analyticsCentre: AnalyticsCentral) {
        self.analyticsCentre = analyticsCentre
        root.navigationBar.isHidden = true
    }
    
    func start() {
        let unlockScreenViewModel = UnlockScreenViewModel(analyticsService: analyticsCentre.analyticsService) { }
        let vc = UnlockScreenViewController(viewModel: unlockScreenViewModel)
        root.setViewControllers([vc], animated: true)
    }
}
