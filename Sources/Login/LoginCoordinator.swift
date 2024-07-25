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
    private let appWindow: UIWindow
    let root: UINavigationController
    weak var parentCoordinator: ParentCoordinator?
    var childCoordinators = [ChildCoordinator]()
    private let analyticsCenter: AnalyticsCentral
    private let userStore: UserStorable
    private let networkMonitor: NetworkMonitoring
    let loginError: Error?
    
    weak var introViewController: IntroViewController?
    private weak var authCoordinator: AuthenticationCoordinator?
    
    init(appWindow: UIWindow,
         root: UINavigationController,
         analyticsCenter: AnalyticsCentral,
         userStore: UserStorable,
         networkMonitor: NetworkMonitoring,
         loginError: Error?) {
        self.appWindow = appWindow
        self.root = root
        self.analyticsCenter = analyticsCenter
        self.userStore = userStore
        self.networkMonitor = networkMonitor
        self.loginError = loginError
        root.modalPresentationStyle = .overFullScreen
    }
    
    func start() {
        let rootViewController = OnboardingViewControllerFactory
            .createIntroViewController(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
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
        root.setViewControllers([rootViewController], animated: true)
        introViewController = rootViewController
        showLoginErrorIfNecessary()
        launchOnboardingCoordinator()
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(returnToIntroScreen),
                         name: Notification.Name(.returnToIntroScreen),
                         object: nil)
    }
    
    private func showLoginErrorIfNecessary() {
        if let error = loginError as? TokenError, error == .launchExpired || error == .useExpired {
            let signOutWarningScreen = ErrorPresenter
                .createSignOutWarning(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                    if userStore.missingPersistentSessionId {
                        root.dismiss(animated: true)
                        NotificationCenter.default.post(name: Notification.Name(.clearWallet), object: nil)
                    } else {
                        if networkMonitor.isConnected {
                            launchAuthenticationCoordinator(reauth: true)
                        } else {
                            root.dismiss(animated: true)
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
            signOutWarningScreen.modalPresentationStyle = .overFullScreen
            root.present(signOutWarningScreen, animated: false)
        } else if let loginError {
            let unableToLoginErrorScreen = ErrorPresenter
                .createUnableToLoginError(errorDescription: loginError.localizedDescription,
                                          analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                    root.dismiss(animated: true)
                }
            unableToLoginErrorScreen.modalPresentationStyle = .overFullScreen
            root.present(unableToLoginErrorScreen, animated: false)
        }
    }
    
    @objc private func returnToIntroScreen() {
        introViewController?.enableIntroButton()
        launchOnboardingCoordinator()
    }
    
    private func launchOnboardingCoordinator() {
        if analyticsCenter.analyticsPreferenceStore.hasAcceptedAnalytics == nil {
            openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsCenter.analyticsPreferenceStore,
                                                   urlOpener: UIApplication.shared))
        }
    }
    
    func launchAuthenticationCoordinator(reauth: Bool = false) {
        let ac = AuthenticationCoordinator(root: root,
                                           analyticsService: analyticsCenter.analyticsService,
                                           userStore: userStore,
                                           session: AppAuthSession(window: appWindow),
                                           reauth: reauth)
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
            if let error = loginError as? TokenError, error == .launchExpired || error == .useExpired {
                userStore.storeTokenInfo()
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
