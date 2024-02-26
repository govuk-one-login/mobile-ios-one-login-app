import Authentication
import Coordination
import Logging
import SecureStore
import UIKit

final class MainCoordinator: NSObject,
                             ParentCoordinator,
                             NavigationCoordinator {
    let window: UIWindow
    let root: UINavigationController
    let analyticsService: AnalyticsService
    let networkMonitor: NetworkMonitoring
    var childCoordinators = [ChildCoordinator]()
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    private let errorPresenter = ErrorPresenter.self
    let tokenHolder = TokenHolder()

    init(window: UIWindow,
         root: UINavigationController,
         analyticsService: AnalyticsService = OneLoginAnalyticsService(),
         networkMonitor: NetworkMonitoring = NetworkMonitor.shared) {
        self.window = window
        self.root = root
        self.analyticsService = analyticsService
        self.networkMonitor = networkMonitor
    }
    
    func start() {
        let introViewController = viewControllerFactory
            .createIntroViewController(analyticsService: analyticsService) { [unowned self] in
                if networkMonitor.isConnected {
                    displayAuthCoordinator()
                } else {
                    let networkErrorScreen = errorPresenter
                        .createNetworkConnectionError(analyticsService: analyticsService) { [unowned self] in
                            root.popViewController(animated: true)
                            if networkMonitor.isConnected {
                                displayAuthCoordinator()
                            }
                        }
                    root.pushViewController(networkErrorScreen, animated: true)
                }
            }
        root.setViewControllers([introViewController], animated: false)
    }
    
    func displayAuthCoordinator() {
        if let authCoordinator = childCoordinators
            .first(where: { $0 is AuthenticationCoordinator }) as? AuthenticationCoordinator {
            authCoordinator.start()
        } else {
            openChildInline(AuthenticationCoordinator(root: root,
                                                      session: AppAuthSession(window: window),
                                                      analyticsService: analyticsService,
                                                      tokenHolder: tokenHolder))
        }
    }
    
    func launchOnboardingCoordinator() {
        guard tokenHolder.tokenResponse != nil else { return }
        let secureStore = SecureStoreService(configuration: .init(id: "oneLoginTokens",
                                                                  accessControlLevel: .anyBiometricsOrPasscode))
        let userStore = UserStorage(secureStoreService: secureStore,
                                    defaultsStore: UserDefaults.standard)
        openChildInline(OnboardingCoordinator(root: root,
                                              userStore: userStore,
                                              analyticsService: analyticsService,
                                              tokenHolder: tokenHolder))
    }
    
    func launchTokenCoordinator() {
        guard tokenHolder.tokenResponse != nil else { return }
        openChildInline(TokenCoordinator(root: root,
                                         tokenHolder: tokenHolder))
    }
    
    func didRegainFocus(fromChild child: ChildCoordinator?) {
        switch child {
        case _ as AuthenticationCoordinator:
            launchOnboardingCoordinator()
        case _ as OnboardingCoordinator:
            launchTokenCoordinator()
        default:
            break
        }
    }
}
