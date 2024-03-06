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
         networkMonitor: NetworkMonitoring = NetworkMonitor.shared,
         analyticsCentre: AnalyticsCentral,
         defaultStore: DefaultsStorable,
         tokenHolder: TokenHolder) {
        self.window = window
        self.root = root
        self.networkMonitor = networkMonitor
        self.analyticsCentre = analyticsCentre
        self.userStore = UserStorage(defaultsStore: defaultStore)
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
                return viewControllerFactory
                    .createIntroViewController(analyticsService: analyticsCentre.analyticsService) { [unowned self] in
                        if networkMonitor.isConnected {
                            launchAuthenticationCoordinator(session: AppAuthSession(window: window))
                        } else {
                            let networkErrorScreen = errorPresenter
                                .createNetworkConnectionError(analyticsService: analyticsCentre.analyticsService) { [unowned self] in
                                    root.popViewController(animated: true)
                                    if networkMonitor.isConnected {
                                        launchAuthenticationCoordinator(session: AppAuthSession(window: window))
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
            tokenHolder.accessToken = try userStore.secureStoreService?.readItem(itemName: "accessToken")
            finish()
        } catch {
            print("error 1: \(error)")
        }
    }
    
    func displayAnalyticsPreferencePage() {
        if analyticsCentre.analyticsPreferenceStore.hasAcceptedAnalytics == nil {
            openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsCentre.analyticsPreferenceStore))
        }
    }
    
    func launchAuthenticationCoordinator(session: LoginSession) {
        openChildInline(AuthenticationCoordinator(root: root,
                                                  session: session,
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
    
    func launchTokenCoordinator() {
        guard tokenHolder.tokenResponse != nil else { return }
        openChildInline(TokenCoordinator(root: root,
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
