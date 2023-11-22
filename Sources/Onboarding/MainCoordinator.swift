import Authentication
import Coordination
import Logging
import UIKit

final class MainCoordinator: NSObject,
                       ParentCoordinator,
                       NavigationCoordinator {
    let window: UIWindow
    let root: UINavigationController
    let analyticsService: AnalyticsService
    var childCoordinators = [ChildCoordinator]()
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    var tokens: TokenResponse?
    
    init(window: UIWindow,
         root: UINavigationController,
         analyticsService: AnalyticsService = OneLoginAnalyticsService()) {
        self.window = window
        self.root = root
        self.analyticsService = analyticsService
    }
    
    func start() {
        let introViewController = viewControllerFactory.createIntroViewController(analyticsService: analyticsService) { [self] in
            openChildInline(AuthenticationCoordinator(root: root, session: AppAuthSession(window: window)))
        }
        root.setViewControllers([introViewController], animated: false)
    }

    func launchTokenCoordinator() {
        guard let tokens else { return }
        openChildInline(TokenCoordinator(root: root, tokens: tokens))
    }

    func didRegainFocus(fromChild child: ChildCoordinator?) {
        switch child {
        case _ as AuthenticationCoordinator:
            launchTokenCoordinator()
        default:
            break
        }
    }
}
