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
    private let sessionManager: SessionManager
    private let networkMonitor: NetworkMonitoring
    private let userState: AppLocalAuthState

    private var introViewController: IntroViewController? {
        root.viewControllers.first as? IntroViewController
    }

    private var authCoordinator: AuthenticationCoordinator? {
        childCoordinators.firstInstanceOf(AuthenticationCoordinator.self)
    }

    init(appWindow: UIWindow,
         root: UINavigationController,
         analyticsCenter: AnalyticsCentral,
         sessionManager: SessionManager,
         networkMonitor: NetworkMonitoring = NetworkMonitor.shared,
         userState: AppLocalAuthState) {
        self.appWindow = appWindow
        self.root = root
        self.analyticsCenter = analyticsCenter
        self.sessionManager = sessionManager
        self.networkMonitor = networkMonitor
        self.userState = userState
        root.modalPresentationStyle = .overFullScreen
    }

    func start() {
        let rootViewController = OnboardingViewControllerFactory
            .createIntroViewController(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                authenticate()
            }
        root.setViewControllers([rootViewController], animated: true)
        showSessionExpiredIfNecessary()
        launchOnboardingCoordinator()
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(returnToIntroScreen),
                         name: Notification.Name(.returnToIntroScreen),
                         object: nil)
    }

    private func showSessionExpiredIfNecessary() {
        if userState == .userExpired {
            let signOutWarningScreen = ErrorPresenter
                .createSignOutWarning(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                    authenticate { [unowned self] in
                        root.dismiss(animated: true)
                    }
                }
            signOutWarningScreen.modalPresentationStyle = .overFullScreen
            root.present(signOutWarningScreen, animated: false)
        }
    }

    func authenticate(action: (() -> Void)? = nil) {
        if sessionManager.isPersistentSessionIDMissing {
            action?()
            NotificationCenter.default.post(name: .clearWallet, object: nil)
        } else {
            if networkMonitor.isConnected {
                launchAuthenticationCoordinator()
            } else {
                action?()
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

    func launchAuthenticationCoordinator() {
        let ac = AuthenticationCoordinator(window: appWindow,
                                           root: root,
                                           analyticsService: analyticsCenter.analyticsService,
                                           sessionManager: sessionManager,
                                           session: AppAuthSession(window: appWindow))
        openChildInline(ac)
    }

    func handleUniversalLink(_ url: URL) {
        authCoordinator?.handleUniversalLink(url)
    }

    func launchEnrolmentCoordinator() {
        openChildInline(EnrolmentCoordinator(root: root,
                                             analyticsService: analyticsCenter.analyticsService,
                                             sessionManager: sessionManager))
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
            if userState == .userExpired,
               sessionManager.isReturningUser {
                finish()
            } else {
                launchEnrolmentCoordinator()
            }
        case _ as EnrolmentCoordinator:
            finish()
        default:
            break
        }
    }
}
