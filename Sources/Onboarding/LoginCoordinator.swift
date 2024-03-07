import Authentication
import Coordination
import Logging
import SecureStore
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
    let tokenHolder: TokenHolder
    
    init(window: UIWindow,
         root: UINavigationController,
         analyticsCentre: AnalyticsCentral,
         networkMonitor: NetworkMonitoring = NetworkMonitor.shared,
         secureStoreService: SecureStorable,
         defaultStore: DefaultsStorable,
         tokenHolder: TokenHolder) {
        self.window = window
        self.root = root
        self.analyticsCentre = analyticsCentre
        self.networkMonitor = networkMonitor
        self.userStore = UserStorage(secureStoreService: secureStoreService,
                                     defaultsStore: defaultStore)
        self.tokenHolder = tokenHolder
    }
    
    func start() {
        var rootViewController: UIViewController {
            if userStore.returningAuthenticatedUser {
                viewControllerFactory
                    .createUnlockScreen(analyticsService: analyticsCentre.analyticsService) { [unowned self] in
                        getAccessToken()
                    }
            } else {
                viewControllerFactory
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
        userStore.returningAuthenticatedUser ? getAccessToken() : launchOnboardingCoordinator()
    }
    
    func getAccessToken() {
        do {
            tokenHolder.accessToken = try userStore.secureStoreService.readItem(itemName: .accessToken)
        } catch {
            print("Local Authentication error: \(error)")
        }
    }
    
    func launchOnboardingCoordinator() {
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
    
    func launchEnrolmentCoordinator() {
        guard tokenHolder.tokenResponse != nil else { return }
        openChildInline(EnrolmentCoordinator(root: root,
                                             userStore: userStore,
                                             analyticsService: analyticsCentre.analyticsService,
                                             tokenHolder: tokenHolder))
    }
    
    func didRegainFocus(fromChild child: ChildCoordinator?) {
        switch child {
        case _ as OnboardingCoordinator:
            return
        case let child as AuthenticationCoordinator where child.loginError != nil:
            return
        case let child as AuthenticationCoordinator where child.loginError == nil:
            launchEnrolmentCoordinator()
        case _ as EnrolmentCoordinator:
            finish()
        default:
            break
        }
    }
}
