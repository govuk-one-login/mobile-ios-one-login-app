import Authentication
import Coordination
import Logging
import UIKit

final class TokenCoordinator: NSObject,
                              ChildCoordinator,
                              NavigationCoordinator {
    var parentCoordinator: ParentCoordinator?
    let root: UINavigationController
    let tokens: TokenResponse
    let analyticsService: AnalyticsService
    
    init(root: UINavigationController,
         tokens: TokenResponse,
         analyticsService: AnalyticsService) {
        self.root = root
        self.tokens = tokens
        self.analyticsService = analyticsService
    }
    
    func start() {
        root.isNavigationBarHidden = true
        let passcodeInformationScreen = OnboardingViewControllerFactory.createPasscodeInformationScreen(analyticsService: analyticsService) {
            self.root.isNavigationBarHidden = true
            let vc = TokensViewController(tokens: self.tokens)
            self.root.pushViewController(vc, animated: true)
        }
        root.pushViewController(passcodeInformationScreen, animated: true)
    }
}
