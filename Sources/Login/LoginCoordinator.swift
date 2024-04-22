import Authentication
import Coordination
import LocalAuthentication
import Logging
import SecureStore
import UIKit

final class LoginCoordinator: NSObject,
                              AnyCoordinator,
                              NavigationCoordinator,
                              ChildCoordinator {
    let windowManager: WindowManagement
    let root: UINavigationController
    var parentCoordinator: ParentCoordinator?
    var childCoordinators = [ChildCoordinator]()
    let analyticsCenter: AnalyticsCentral
    let networkMonitor: NetworkMonitoring
    let userStore: UserStorable
    let tokenHolder: TokenHolder
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    private let errorPresenter = ErrorPresenter.self
    private weak var authCoordinator: AuthenticationCoordinator?
    
    init(windowManager: WindowManagement,
         root: UINavigationController,
         analyticsCenter: AnalyticsCentral,
         networkMonitor: NetworkMonitoring,
         userStore: UserStorable,
         tokenHolder: TokenHolder) {
        self.windowManager = windowManager
        self.root = root
        self.analyticsCenter = analyticsCenter
        self.networkMonitor = networkMonitor
        self.userStore = userStore
        self.tokenHolder = tokenHolder
        root.modalPresentationStyle = .overFullScreen
    }
    
    func start() {
        if userStore.returningAuthenticatedUser {
            returningUserFlow()
        } else {
            userStore.refreshStorage(accessControlLevel: LAContext().isPasscodeOnly ? .anyBiometricsOrPasscode : .currentBiometricsOrPasscode)
            firstTimeUserFlow()
        }
    }
    
    func returningUserFlow() {
        windowManager.displayUnlockWindow(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
            getAccessToken()
        }
        getAccessToken()
    }
    
    func getAccessToken() {
        do {
            tokenHolder.accessToken = try userStore.secureStoreService.readItem(itemName: .accessToken)
            windowManager.hideUnlockWindow()
            root.dismiss(animated: true)
            finish()
        } catch SecureStoreError.unableToRetrieveFromUserDefaults,
                SecureStoreError.cantInitialiseData,
                SecureStoreError.cantRetrieveKey {
            userStore.refreshStorage(accessControlLevel: LAContext().isPasscodeOnly ? .anyBiometricsOrPasscode : .currentBiometricsOrPasscode)
            windowManager.hideUnlockWindow()
            start()
        } catch {
            print("Local Authentication error: \(error)")
        }
    }
    
    func firstTimeUserFlow() {
        let rootViewController = viewControllerFactory
            .createIntroViewController(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                if networkMonitor.isConnected {
                    launchAuthenticationCoordinator()
                } else {
                    let networkErrorScreen = errorPresenter
                        .createNetworkConnectionError(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
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
        if analyticsCenter.analyticsPreferenceStore.hasAcceptedAnalytics == nil {
            openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsCenter.analyticsPreferenceStore,
                                                   urlOpener: UIApplication.shared))
        }
    }
    
    func launchAuthenticationCoordinator() {
        let ac = AuthenticationCoordinator(root: root,
                                           session: AppAuthSession(window: windowManager.appWindow),
                                           analyticsService: analyticsCenter.analyticsService,
                                           tokenHolder: tokenHolder)
        openChildInline(ac)
        self.authCoordinator = ac
    }
    
    func handleUniversalLink(_ url: URL) {
        authCoordinator?.handleUniversalLink(url)
    }
    
    func launchEnrolmentCoordinator(localAuth: LAContexting) {
        openChildInline(EnrolmentCoordinator(root: root,
                                             analyticsService: analyticsCenter.analyticsService,
                                             userStore: userStore,
                                             localAuth: localAuth,
                                             tokenHolder: tokenHolder))
    }
}

extension LoginCoordinator: ParentCoordinator {
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
