import Authentication
import Coordination
import Logging
import Network
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
    let monitor = NWPathMonitor()
    var isNetworkConnected: Bool = true

    init(window: UIWindow,
         root: UINavigationController,
         analyticsService: AnalyticsService = OneLoginAnalyticsService()) {
        self.window = window
        self.root = root
        self.analyticsService = analyticsService
    }
    
    func start() {
        checkNetworkConnection()
        if isNetworkConnected {
            let introViewController = viewControllerFactory.createIntroViewController(analyticsService: analyticsService) { [self] in
                if let authCoordinator = childCoordinators.first(where: { $0 is AuthenticationCoordinator }) as? AuthenticationCoordinator {
                    authCoordinator.start()
                } else {
                    checkNetworkConnection()
                    if isNetworkConnected {
                        openChildInline(AuthenticationCoordinator(root: root,
                                                                  session: AppAuthSession(window: window),
                                                                  errorPresenter: errorPresenter,
                                                                  analyticsService: analyticsService))
                    } else {
                        let networkErrorScreen = errorPresenter.createNetworkConnectionError(analyticsService: analyticsService) {
                            self.root.popViewController(animated: true)
                        }
                        root.pushViewController(networkErrorScreen, animated: true)
                    }

                }
            }
            root.setViewControllers([introViewController], animated: false)
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

    func checkNetworkConnection() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connected!")
                self.isNetworkConnected = true
            } else {
                self.isNetworkConnected = false
                print("Houston we are offline")
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
