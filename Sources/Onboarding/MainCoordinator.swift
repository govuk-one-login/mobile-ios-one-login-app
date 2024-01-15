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
    private let networkMonitor = NetworkMonitor()
    var tokens: TokenResponse?

    init(window: UIWindow,
         root: UINavigationController,
         analyticsService: AnalyticsService = OneLoginAnalyticsService()) {
        self.window = window
        self.root = root
        self.analyticsService = analyticsService
    }
    
    func start() {

        if networkMonitor.isConnected {
            let introViewController = viewControllerFactory.createIntroViewController(analyticsService: analyticsService) { [self] in
                if let authCoordinator = childCoordinators.first(where: { $0 is AuthenticationCoordinator }) as? AuthenticationCoordinator {
                    authCoordinator.start()
                } else {

                    if !networkMonitor.isConnected {
                        let networkErrorScreen = errorPresenter.createNetworkConnectionError(analyticsService: analyticsService) {
                            self.root.popViewController(animated: true)
                        }
                        root.pushViewController(networkErrorScreen, animated: true)
                    } else {
                        openChildInline(AuthenticationCoordinator(root: root,
                                                                  session: AppAuthSession(window: window),
                                                                  errorPresenter: errorPresenter,
                                                                  analyticsService: analyticsService))
                    }
                }
            }
            root.setViewControllers([introViewController], animated: false)
        }
        // This will show the error screen first if the app starts offline
//        if !networkMonitor.isConnected {
//            let networkErrorScreen = errorPresenter.createNetworkConnectionError(analyticsService: analyticsService) {
//                self.root.popViewController(animated: true)
//            }
//            root.pushViewController(networkErrorScreen, animated: true)
//        }
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
