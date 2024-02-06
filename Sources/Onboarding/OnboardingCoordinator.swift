import Coordination
import LocalAuthentication
import Logging
import UIKit

final class OnboardingCoordinator: NSObject,
                                   ChildCoordinator,
                                   NavigationCoordinator {
    let root: UINavigationController
    var parentCoordinator: ParentCoordinator?
    let localAuth: LAContexting
    let analyticsService: AnalyticsService
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    
    init(root: UINavigationController,
         analyticsService: AnalyticsService,
         localAuth: LAContexting = LAContext()) {
        self.root = root
        self.analyticsService = analyticsService
        self.localAuth = localAuth
    }
    
    func start() {
        if !localAuth.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            root.isNavigationBarHidden = true
            let passcodeInformationScreen = viewControllerFactory
                .createPasscodeInformationScreen(analyticsService: analyticsService) { [unowned self] in
                    finish()
                }
            root.pushViewController(passcodeInformationScreen, animated: true)
        } else {
            finish()
        }
    }
}
