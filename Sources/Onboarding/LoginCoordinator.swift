import Authentication
import Coordination
import Logging
import UIKit

final class LoginCoordinator: NSObject,
                              AnyCoordinator,
                              NavigationCoordinator,
                              ParentCoordinator,
                              ChildCoordinator {
    let window: UIWindow
    let root: UINavigationController
    var parentCoordinator: ParentCoordinator?
    var childCoordinators = [ChildCoordinator]()
    let analyticsCentre: AnalyticsCentral
    let networkMonitor: NetworkMonitoring
    let userStore: UserStorable
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    private let errorPresenter = ErrorPresenter.self
    let tokenHolder = TokenHolder()
    
    init(window: UIWindow,
         root: UINavigationController,
         networkMonitor: NetworkMonitoring = NetworkMonitor.shared,
         analyticsCentre: AnalyticsCentral,
         userStore: UserStorable) {
        self.window = window
        self.root = root
        self.networkMonitor = networkMonitor
        self.analyticsCentre = analyticsCentre
        self.userStore = userStore
    }
    
    func start() {
        var rootViewController: UIViewController {
            if userStore.returningAuthenticatedUser {
                return viewControllerFactory
                    .createUnlockScreen(analyticsService: analyticsCentre.analyticsService) { [unowned self] in
                        getAccessToken()
                    }
            } else {
                return viewControllerFactory
                    .createIntroViewController(analyticsService: analyticsCentre.analyticsService) { [unowned self] in
                        if networkMonitor.isConnected {
                            launchAuthenticationCoordinator()
                        } else {
                            let networkErrorScreen = errorPresenter
                                .createNetworkConnectionError(analyticsService: analyticsCentre.analyticsService) { [unowned self] in
                                    root.popViewController(animated: true)
                                    if networkMonitor.isConnected {
                                        launchAuthenticationCoordinator()
                                    }
                                }
                            root.pushViewController(networkErrorScreen, animated: true)
                        }
                    }
            }
        }
        root.setViewControllers([rootViewController], animated: true)
        userStore.returningAuthenticatedUser ? getAccessToken() : displayAnalyticsPreferencePage()
    }
    
    func getAccessToken() {
        do {
            _ = try userStore.secureStoreService.readItem(itemName: "accessToken")
        } catch {
            print("error 1: \(error)")
        }
    }
    
    func displayAnalyticsPreferencePage() {
        if analyticsCentre.analyticsPreferenceStore.hasAcceptedAnalytics == nil {
            openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsCentre.analyticsPreferenceStore))
        }
    }
    
    func launchAuthenticationCoordinator() {
        openChildInline(AuthenticationCoordinator(root: root,
                                                  session: AppAuthSession(window: window),
                                                  analyticsService: analyticsCentre.analyticsService,
                                                  tokenHolder: tokenHolder))
    }
}
