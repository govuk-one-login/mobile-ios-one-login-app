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
    private let isExpiredUser: Bool

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
         isExpiredUser: Bool) {
        self.appWindow = appWindow
        self.root = root
        self.analyticsCenter = analyticsCenter
        self.sessionManager = sessionManager
        self.networkMonitor = networkMonitor
        self.isExpiredUser = isExpiredUser
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(launchOnboardingCoordinator),
            name: .didHitSignIn
        )
    }

    func start() {
        let rootViewController: UIViewController

        if isExpiredUser {
            let viewModel = SignOutWarningViewModel(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                authenticate()
            }
            rootViewController = GDSErrorViewController(viewModel: viewModel)
        } else {
            let viewModel = OneLoginIntroViewModel(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                authenticate()
            }
            rootViewController = IntroViewController(viewModel: viewModel)
        }

        root.setViewControllers([rootViewController], animated: true)
    }

    func authenticate() {
        guard networkMonitor.isConnected else {
            let viewModel = NetworkConnectionErrorViewModel(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                introViewController?.enableIntroButton()
                root.popViewController(animated: true)
                if networkMonitor.isConnected {
                    launchAuthenticationCoordinator()
                }
            }
            let networkErrorScreen = GDSErrorViewController(viewModel: viewModel)
            root.pushViewController(networkErrorScreen, animated: true)
            return
        }

        launchAuthenticationCoordinator()
    }

    @objc private func launchOnboardingCoordinator() {
        if analyticsCenter.analyticsPermissionsNotSet {
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
        case let child as AuthenticationCoordinator where child.authError != nil:
            root.popToRootViewController(animated: true)
            introViewController?.enableIntroButton()
        case is AuthenticationCoordinator where sessionManager.isReturningUser:
            finish()
        case is AuthenticationCoordinator:
            launchEnrolmentCoordinator()
        case is EnrolmentCoordinator:
            finish()
        default:
            break
        }
    }
}
