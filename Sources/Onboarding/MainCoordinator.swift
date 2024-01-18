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
    private let errorPresenter = ErrorPresenter.self
    var tokens: TokenResponse?
    
    init(window: UIWindow,
         root: UINavigationController,
         analyticsService: AnalyticsService = OneLoginAnalyticsService()) {
        self.window = window
        self.root = root
        self.analyticsService = analyticsService
    }
    
    func start() {
        let introViewController = viewControllerFactory.createIntroViewController(analyticsService: analyticsService) { [unowned self] in
            if NetworkMonitor.shared.isConnected {
                displayAuthCoordinator()
            } else {
                let networkErrorScreen = errorPresenter.createNetworkConnectionError(analyticsService: analyticsService) {
                    if NetworkMonitor.shared.isConnected {
                        self.root.popViewController(animated: true)
                        self.displayAuthCoordinator()
                    }
                }
                root.pushViewController(networkErrorScreen, animated: true)
            }
        }
        root.setViewControllers([introViewController], animated: false)
    }
    
    func displayAuthCoordinator() {
        if let authCoordinator = childCoordinators.first(where: { $0 is AuthenticationCoordinator }) as? AuthenticationCoordinator {
            authCoordinator.start()
        } else {
            openChildInline(AuthenticationCoordinator(root: root,
                                                      session: AppAuthSession(window: window),
                                                      errorPresenter: errorPresenter,
                                                      analyticsService: analyticsService))
        }
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
