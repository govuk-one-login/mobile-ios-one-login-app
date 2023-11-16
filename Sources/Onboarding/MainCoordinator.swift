import Authentication
import Coordination
import Logging
import UIKit

final class MainCoordinator: NSObject,
                             ParentCoordinator,
                             NavigationCoordinator {
    let root: UINavigationController
    let session: LoginSession
    let analyticsService: AnalyticsService
    var childCoordinators = [ChildCoordinator]()
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    var authCoordinator: AuthenticationCoordinator?
    
    init(root: UINavigationController,
         session: LoginSession,
         analyticsService: AnalyticsService = OneLoginAnalyticsService()) {
        self.root = root
        self.session = session
        self.analyticsService = analyticsService
    }
    
    func start() {
        authCoordinator = AuthenticationCoordinator(root: root,
                                                    session: session)
        let introViewController = viewControllerFactory.createIntroViewController(analyticsService: analyticsService,
                                                                                  session: session) { [self] in
            guard let authCoordinator else { return }
            openChildInline(authCoordinator)
        }
    }
}
