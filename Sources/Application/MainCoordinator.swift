import Authentication
import Coordination
import GAnalytics
import Logging
import SecureStore
import UIKit

final class MainCoordinator: NSObject,
                             AnyCoordinator,
                             ParentCoordinator,
                             NavigationCoordinator {
    let window: UIWindow
    let root: UINavigationController
    let analyticsCentre: AnalyticsCentral
    let networkMonitor: NetworkMonitoring
    var childCoordinators = [ChildCoordinator]()
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    private let errorPresenter = ErrorPresenter.self
    var tokenHolder = TokenHolder()
    let userStore: UserStorage

    init(window: UIWindow,
         root: UINavigationController,
         analyticsCentre: AnalyticsCentral,
         networkMonitor: NetworkMonitoring = NetworkMonitor.shared,
         secureStore: SecureStorable,
         defaultStore: DefaultsStorable) {
        self.window = window
        self.root = root
        self.analyticsCentre = analyticsCentre
        self.networkMonitor = networkMonitor
        self.userStore = UserStorage(secureStoreService: secureStore,
                                     defaultsStore: defaultStore)
    }
    
    func start() {
        if (userStore.defaultsStore.value(forKey: "returningUser") != nil) && (userStore.defaultsStore.value(forKey: "accessTokenExpiry") != nil) {
            let unlockScreenViewController = viewControllerFactory
                .createUnlockScreen(analyticsService: analyticsService) {

                }
            root.setViewControllers([unlockScreenViewController], animated: true)
            do {
                let accessToken = try userStore.secureStoreService.readItem(itemName: "accessToken")
                print("ACCESS TOKEN: \(accessToken)")
            } catch {
                print("error retrieving token")
            }
        } else {
            let introViewController = viewControllerFactory
                .createIntroViewController(analyticsService: analyticsCentre.analyticsService) { [unowned self] in
                    if networkMonitor.isConnected {
                        displayAuthCoordinator()
                    } else {
                        let networkErrorScreen = errorPresenter
                            .createNetworkConnectionError(analyticsService: analyticsCentre.analyticsService) { [unowned self] in
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
        displayAnalyticsPreferencePage()
    }
    
    func displayAnalyticsPreferencePage() {
        if analyticsCentre.analyticsPreferenceStore.hasAcceptedAnalytics == nil {
            openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsCentre.analyticsPreferenceStore))
        }
    }
    
    func displayAuthCoordinator() {
        if let authCoordinator = childCoordinators
            .first(where: { $0 is AuthenticationCoordinator }) as? AuthenticationCoordinator {
            authCoordinator.start()
        } else {
            openChildInline(AuthenticationCoordinator(root: root,
                                                      session: AppAuthSession(window: window),
                                                      analyticsService: analyticsCentre.analyticsService,
                                                      tokenHolder: tokenHolder))
        }
    }
    
    func launchOnboardingCoordinator() {
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
        case _ as AuthenticationCoordinator:
            launchOnboardingCoordinator()
        case _ as EnrolmentCoordinator:
            launchTokenCoordinator()
        default:
            break
        }
    }
}
