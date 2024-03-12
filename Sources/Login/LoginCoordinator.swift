import Authentication
import Coordination
import LocalAuthentication
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
    private weak var authCoordinator: AuthenticationCoordinator?
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
                return viewControllerFactory
                    .createUnlockScreen(analyticsService: analyticsCentre.analyticsService) { [unowned self] in
                        getAccessToken()
                    }
            } else {
                userStore.refreshSecureStoreService()
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
        userStore.returningAuthenticatedUser ? getAccessToken() : launchOnboardingCoordinator()
    }
    
    func getAccessToken() {
        if userStore.validAccessToken {
            do {
                tokenHolder.accessToken = try userStore.secureStoreService.readItem(itemName: .accessToken)
            } catch {
                print("Local Authentication error: \(error)")
            }
        } else {
            do {
                try userStore.clearTokenInfo()
                start()
            } catch {
                print("Clearing Token Info error: \(error)")
            }
        }
    }
    
    func launchOnboardingCoordinator() {
        if analyticsCentre.analyticsPreferenceStore.hasAcceptedAnalytics == nil {
            openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsCentre.analyticsPreferenceStore))
        }
    }
    
    func launchAuthenticationCoordinator() {
        let ac = AuthenticationCoordinator(root: root,
                                           session: AppAuthSession(window: window),
                                           analyticsService: analyticsCentre.analyticsService,
                                           tokenHolder: tokenHolder)
        openChildInline(ac)
        self.authCoordinator = ac
    }
    
    func handleUniversalLink(_ url: URL) {
        authCoordinator?.handleUniversalLink(url)
    }
    
    func launchEnrolmentCoordinator(localAuth: LAContexting) {
        guard tokenHolder.tokenResponse != nil else { return }
        openChildInline(EnrolmentCoordinator(root: root,
                                             analyticsService: analyticsCentre.analyticsService,
                                             userStore: userStore,
                                             localAuth: localAuth,
                                             tokenHolder: tokenHolder))
    }
    
    func didRegainFocus(fromChild child: ChildCoordinator?) {
        switch child {
        case _ as OnboardingCoordinator:
            return
        case let child as AuthenticationCoordinator where child.loginError != nil:
            return
        case let child as AuthenticationCoordinator where child.loginError == nil:
            launchEnrolmentCoordinator(localAuth: LAContext())
        case _ as EnrolmentCoordinator:
            finish()
        default:
            break
        }
    }
}
