import Authentication
import Coordination
import Logging
import UIKit

final class ReauthCoordinator: NSObject,
                               AnyCoordinator,
                               NavigationCoordinator,
                               ChildCoordinator {
    let window: UIWindow
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?
    var childCoordinators = [ChildCoordinator]()
    let analyticsService: AnalyticsService
    let userStore: UserStorable
    private weak var authCoordinator: AuthenticationCoordinator?

    init(window: UIWindow,
         analyticsService: AnalyticsService,
         userStore: UserStorable) {
        self.window = window
        self.analyticsService = analyticsService
        self.userStore = userStore
        root.modalPresentationStyle = .overFullScreen
    }
    
    func start() {
        let signOutWarning = ErrorPresenter.createSignoutWarning(analyticsService: analyticsService) { [unowned self] in
            let ac = AuthenticationCoordinator(root: root,
                                               analyticsService: analyticsService,
                                               userStore: userStore,
                                               session: AppAuthSession(window: window))
            openChildInline(ac)
            authCoordinator = ac
        }
        root.setViewControllers([signOutWarning], animated: false)
    }
    
    func handleUniversalLink(_ url: URL) {
        authCoordinator?.handleUniversalLink(url)
    }
}

extension ReauthCoordinator: ParentCoordinator {
    func didRegainFocus(fromChild child: ChildCoordinator?) {
        root.dismiss(animated: true)
    }
}
