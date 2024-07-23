import Authentication
import Coordination
import GDSCommon
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
    weak var parentCoordinator: ParentCoordinator?
    var childCoordinators = [ChildCoordinator]()
    private let analyticsCenter: AnalyticsCentral
    private let userStore: UserStorable
    private let networkMonitor: NetworkMonitoring
    private let reauth: Bool
    var loginError: Error?
    
    weak var introViewController: IntroViewController?
    private weak var authCoordinator: AuthenticationCoordinator?
    
    init(windowManager: WindowManagement,
         root: UINavigationController,
         analyticsCenter: AnalyticsCentral,
         userStore: UserStorable,
         networkMonitor: NetworkMonitoring,
         reauth: Bool) {
        self.windowManager = windowManager
        self.root = root
        self.analyticsCenter = analyticsCenter
        self.userStore = userStore
        self.networkMonitor = networkMonitor
        self.reauth = reauth
        root.modalPresentationStyle = .overFullScreen
    }
    
    func start() {
        if reauth {
            let rootViewController = ErrorPresenter
                .createSignOutWarning(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                    authenticate()
                }
            root.setViewControllers([rootViewController], animated: true)
        } else {
            let rootViewController = OnboardingViewControllerFactory
                .createIntroViewController(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                    authenticate()
                }
            root.setViewControllers([rootViewController], animated: true)
            introViewController = rootViewController
            showLoginErrorIfNecessary()
            launchOnboardingCoordinator()
        }
    }
    
    private func authenticate() {
        if userStore.missingPersistentSessionId {
            NotificationCenter.default.post(name: Notification.Name(.clearWallet), object: nil)
        } else {
            if networkMonitor.isConnected {
                launchAuthenticationCoordinator()
            } else {
                let networkErrorScreen = ErrorPresenter
                    .createNetworkConnectionError(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                        introViewController?.enableIntroButton()
                        root.popViewController(animated: true)
                        if networkMonitor.isConnected {
                            launchAuthenticationCoordinator()
                        }
                    }
                root.pushViewController(networkErrorScreen, animated: true)
            }
        }
    }
    
    private func showLoginErrorIfNecessary() {
        if let error = loginError as? TokenError, error == .expired {
            let signOutWarningScreen = ErrorPresenter
                .createSignOutWarning(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                    root.dismiss(animated: true) { [unowned self] in
                        if userStore.missingPersistentSessionId {
                            NotificationCenter.default.post(name: Notification.Name(.clearWallet), object: nil)
                        }
                        launchOnboardingCoordinator()
                    }
                }
            signOutWarningScreen.modalPresentationStyle = .overFullScreen
            root.present(signOutWarningScreen, animated: false)
        } else if let loginError {
            let unableToLoginErrorScreen = ErrorPresenter
                .createUnableToLoginError(errorDescription: loginError.localizedDescription,
                                          analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                    root.popViewController(animated: true)
                }
            root.pushViewController(unableToLoginErrorScreen, animated: true)
        }
    }
    
    private func launchOnboardingCoordinator() {
        if analyticsCenter.analyticsPreferenceStore.hasAcceptedAnalytics == nil {
            openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsCenter.analyticsPreferenceStore,
                                                   urlOpener: UIApplication.shared))
        }
    }
    
    func launchAuthenticationCoordinator() {
        let ac = AuthenticationCoordinator(root: root,
                                           analyticsService: analyticsCenter.analyticsService,
                                           userStore: userStore,
                                           session: AppAuthSession(window: windowManager.appWindow))
        openChildInline(ac)
        authCoordinator = ac
    }
    
    func handleUniversalLink(_ url: URL) {
        authCoordinator?.handleUniversalLink(url)
    }
    
    func launchEnrolmentCoordinator(localAuth: LAContexting) {
        openChildInline(EnrolmentCoordinator(root: root,
                                             analyticsService: analyticsCenter.analyticsService,
                                             userStore: userStore,
                                             localAuth: localAuth))
    }
}

extension LoginCoordinator: ParentCoordinator {
    func didRegainFocus(fromChild child: ChildCoordinator?) {
        switch child {
        case _ as OnboardingCoordinator:
            return
        case let child as AuthenticationCoordinator where child.authError != nil:
            introViewController?.enableIntroButton()
        case let child as AuthenticationCoordinator where child.authError == nil:
            if reauth {
                root.dismiss(animated: true)
                finish()
            } else {
                launchEnrolmentCoordinator(localAuth: LAContext())
            }
        case _ as EnrolmentCoordinator:
            root.dismiss(animated: true)
            finish()
        default:
            break
        }
    }
}
