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
    let tokenHolder: TokenHolder
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    private let errorPresenter = ErrorPresenter.self
    private weak var authCoordinator: AuthenticationCoordinator?
    
    init(window: UIWindow,
         root: UINavigationController,
         analyticsCentre: AnalyticsCentral,
         networkMonitor: NetworkMonitoring,
         userStore: UserStorable,
         tokenHolder: TokenHolder) {
        self.window = window
        self.root = root
        self.analyticsCentre = analyticsCentre
        self.networkMonitor = networkMonitor
        self.userStore = userStore
        self.tokenHolder = tokenHolder
        root.modalPresentationStyle = .overFullScreen
    }
    
    func start() {
        if userStore.returningAuthenticatedUser {
            returningUserFlow()
        } else {
            userStore.refreshStorage(accessControlLevel: .currentBiometricsOrPasscode)
            firstTimeUserFlow()
        }
    }
    
    func returningUserFlow() {
        let rootViewController = viewControllerFactory
            .createUnlockScreen(analyticsService: analyticsCentre.analyticsService) { [unowned self] in
                getAccessToken()
            }
        root.setViewControllers([rootViewController], animated: true)
        getAccessToken()
    }
    
    func getAccessToken() {
        do {
            tokenHolder.accessToken = try userStore.secureStoreService.readItem(itemName: .accessToken)
            root.dismiss(animated: true)
            finish()
        } catch SecureStoreError.unableToRetrieveFromUserDefaults,
                SecureStoreError.cantInitialiseData,
                SecureStoreError.cantRetrieveKey {
            userStore.refreshStorage(accessControlLevel: .currentBiometricsOrPasscode)
            start()
        } catch {
            print("Local Authentication error: \(error)")
        }
    }
    
    func firstTimeUserFlow() {
        let rootViewController = viewControllerFactory
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
        root.setViewControllers([rootViewController], animated: true)
        launchOnboardingCoordinator()
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
            root.dismiss(animated: true)
            finish()
        default:
            break
        }
    }
}
