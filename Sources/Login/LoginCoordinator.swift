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
    let analyticsCenter: AnalyticsCentral
    var userStore: UserStorable
    let networkMonitor: NetworkMonitoring
    let tokenHolder: TokenHolder
    private var tokenVerifier: TokenVerifier
    var loginError: Error?
    
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    private let errorPresenter = ErrorPresenter.self
    
    weak var introViewController: IntroViewController?
    private weak var authCoordinator: AuthenticationCoordinator?
    
    init(windowManager: WindowManagement,
         root: UINavigationController,
         analyticsCenter: AnalyticsCentral,
         userStore: UserStorable,
         networkMonitor: NetworkMonitoring,
         tokenHolder: TokenHolder,
         tokenVerifier: TokenVerifier = JWTVerifier()) {
        self.windowManager = windowManager
        self.root = root
        self.analyticsCenter = analyticsCenter
        self.userStore = userStore
        self.networkMonitor = networkMonitor
        self.tokenHolder = tokenHolder
        self.tokenVerifier = tokenVerifier
        root.modalPresentationStyle = .overFullScreen
    }
    
    func start() {
        let rootViewController = viewControllerFactory
            .createIntroViewController(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                if networkMonitor.isConnected {
                    launchAuthenticationCoordinator()
                } else {
                    let networkErrorScreen = errorPresenter
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
        root.setViewControllers([rootViewController], animated: true)
        introViewController = rootViewController
        if let loginError {
            let unableToLoginErrorScreen = ErrorPresenter
                .createUnableToLoginError(errorDescription: loginError.localizedDescription,
                                          analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                    root.popViewController(animated: true)
                }
            root.pushViewController(unableToLoginErrorScreen, animated: true)
        }
        launchOnboardingCoordinator()
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
                                           session: AppAuthSession(window: windowManager.appWindow),
                                           tokenHolder: tokenHolder)
        openChildInline(ac)
        authCoordinator = ac
    }
    
    func handleUniversalLink(_ url: URL) {
        // WHEN the handleUniversalLink method is called
        // This test is purely to get test coverage atm as we will not be able to test for effects on unmocked subcoordinators
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
        case let child as AuthenticationCoordinator where child.authError != nil:
            introViewController?.enableIntroButton()
            return
        case let child as AuthenticationCoordinator where child.authError == nil:
            launchEnrolmentCoordinator(localAuth: LAContext())
        case _ as EnrolmentCoordinator:
            root.dismiss(animated: true)
            finish()
        default:
            break
        }
    }
}
