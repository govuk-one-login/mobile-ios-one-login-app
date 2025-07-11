import Authentication
import Coordination
import GDSAnalytics
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
    
    private let analyticsService: OneLoginAnalyticsService
    private let analyticsPreferenceStore: AnalyticsPreferenceStore
    private let sessionManager: SessionManager
    private let networkMonitor: NetworkMonitoring
    private let authService: AuthenticationService
    private var isExpiredUser: Bool
    
    private var loginTask: Task<Void, Never>? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    init(appWindow: UIWindow,
         root: UINavigationController,
         analyticsService: OneLoginAnalyticsService,
         analyticsPreferenceStore: AnalyticsPreferenceStore,
         sessionManager: SessionManager,
         networkMonitor: NetworkMonitoring = NetworkMonitor.shared,
         authService: AuthenticationService,
         isExpiredUser: Bool) {
        self.appWindow = appWindow
        self.root = root
        self.analyticsService = analyticsService
        self.analyticsPreferenceStore = analyticsPreferenceStore
        self.sessionManager = sessionManager
        self.networkMonitor = networkMonitor
        self.authService = authService
        self.isExpiredUser = isExpiredUser
    }
    
    deinit {
        loginTask?.cancel()
    }
    
    func start() {
        let rootViewController: UIViewController
        
        if isExpiredUser {
            let viewModel = SignOutWarningViewModel(analyticsService: analyticsService) { [unowned self] in
                authenticate()
            }
            rootViewController = GDSInformationViewController(viewModel: viewModel)
        } else {
            let viewModel = OneLoginIntroViewModel(analyticsService: analyticsService) { [unowned self] in
                authenticate()
            }
            rootViewController = IntroViewController(viewModel: viewModel)
        }
        
        root.setViewControllers([rootViewController], animated: true)
    }
    
    func authenticate() {
        let numbers = [0]
        _ = numbers[1]
        
        guard networkMonitor.isConnected else {
            showNetworkConnectionErrorScreen { [unowned self] in
                returnFromErrorScreen()
                if networkMonitor.isConnected {
                    launchAuthenticationService()
                }
            }
            return
        }
        launchAuthenticationService()
    }
    
    func launchAuthenticationService() {
        loginTask = Task {
            do {
                try await triggerAuthFlow()
            } catch PersistentSessionError.sessionMismatch {
                showDataDeletedWarningScreen()
            } catch PersistentSessionError.cannotDeleteData(let error) {
                showRecoverableErrorScreen(error)
            } catch let error as LoginErrorV2 where error.reason == .authorizationAccessDenied {
                showDataDeletedWarningScreen()
            } catch let error as LoginErrorV2 where error.reason == .userCancelled {
                enableAuthButton()
            } catch let error as LoginErrorV2 where error.reason == .network {
                showNetworkConnectionErrorScreen { [unowned self] in
                    returnFromErrorScreen()
                }
            } catch let error as LoginErrorV2 where error.reason == .authorizationInvalidRequest,
                    let error as LoginErrorV2 where error.reason == .authorizationUnauthorizedClient,
                    let error as LoginErrorV2 where error.reason == .authorizationUnsupportedResponseType,
                    let error as LoginErrorV2 where error.reason == .authorizationInvalidScope,
                    let error as LoginErrorV2 where error.reason == .authorizationTemporarilyUnavailable,
                    let error as LoginErrorV2 where error.reason == .tokenInvalidRequest,
                    let error as LoginErrorV2 where error.reason == .tokenUnauthorizedClient,
                    let error as LoginErrorV2 where error.reason == .tokenInvalidScope,
                    let error as LoginErrorV2 where error.reason == .tokenInvalidClient,
                    let error as LoginErrorV2 where error.reason == .tokenInvalidGrant,
                    let error as LoginErrorV2 where error.reason == .tokenUnsupportedGrantType,
                    let error as LoginErrorV2 where error.reason == .tokenClientError {
                showUnrecoverableErrorScreen(error)
            } catch let error as LoginErrorV2 where error.reason == .authorizationServerError,
                    let error as LoginErrorV2 where error.reason == .authorizationUnknownError,
                    let error as LoginErrorV2 where error.reason == .tokenUnknownError,
                    let error as LoginErrorV2 where error.reason == .generalServerError,
                    let error as LoginErrorV2 where error.reason == .safariOpenError {
                showRecoverableErrorScreen(error)
            } catch let error as JWTVerifierError {
                showRecoverableErrorScreen(error)
            } catch {
                showGenericErrorScreen(error)
            }
        }
    }
    
    private func triggerAuthFlow() async throws {
        try await authService.startWebSession()
        guard sessionManager.isReturningUser else {
            launchEnrolmentCoordinator()
            return
        }
        finish()
    }
    
    func handleUniversalLink(_ url: URL) {
        let loginLoadingScreen = GDSLoadingViewController(
            viewModel: LoginLoadingViewModel(
                analyticsService: analyticsService
            )
        )
        root.pushViewController(loginLoadingScreen, animated: false)
        do {
            try authService.handleUniversalLink(url)
        } catch {
            showGenericErrorScreen(error)
        }
    }
    
    func launchOnboardingCoordinator() {
        if analyticsPreferenceStore.hasAcceptedAnalytics == nil, root.topViewController is IntroViewController {
            openChildModally(OnboardingCoordinator(analyticsService: analyticsService,
                                                   analyticsPreferenceStore: analyticsPreferenceStore,
                                                   urlOpener: UIApplication.shared))
        }
    }
    
    func launchEnrolmentCoordinator() {
        openChildInline(EnrolmentCoordinator(root: root,
                                             analyticsService: analyticsService,
                                             sessionManager: sessionManager))
    }
}

extension LoginCoordinator {
    private func showDataDeletedWarningScreen() {
        let viewModel = DataDeletedWarningViewModel { [unowned self] in
            isExpiredUser = false
            start()
            launchOnboardingCoordinator()
        }
        let vc = GDSErrorScreen(viewModel: viewModel)
        root.pushViewController(vc, animated: true)
    }
    
    private func showRecoverableErrorScreen(_ error: Error) {
        let viewModel = RecoverableLoginErrorViewModel(analyticsService: analyticsService,
                                                       errorDescription: error.localizedDescription) { [unowned self] in
            returnFromErrorScreen()
        }
        let unableToLoginErrorScreen = GDSErrorScreen(viewModel: viewModel)
        root.pushViewController(unableToLoginErrorScreen, animated: true)
    }
    
    private func showUnrecoverableErrorScreen(_ error: Error) {
        let viewModel = UnrecoverableLoginErrorViewModel(analyticsService: analyticsService,
                                                         errorDescription: error.localizedDescription)
        let unableToLoginErrorScreen = GDSErrorScreen(viewModel: viewModel)
        root.pushViewController(unableToLoginErrorScreen, animated: true)
    }
    
    private func showNetworkConnectionErrorScreen(action: @escaping () -> Void) {
        let viewModel = NetworkConnectionErrorViewModel(analyticsService: analyticsService) {
            action()
        }
        let networkErrorScreen = GDSErrorScreen(viewModel: viewModel)
        root.pushViewController(networkErrorScreen, animated: true)
    }
    
    private func showGenericErrorScreen(_ error: Error) {
        let viewModel = GenericErrorViewModel(analyticsService: analyticsService,
                                              errorDescription: error.localizedDescription) { [unowned self] in
            returnFromErrorScreen()
        }
        let genericErrorScreen = GDSErrorScreen(viewModel: viewModel)
        root.pushViewController(genericErrorScreen, animated: true)
    }
    
    private func returnFromErrorScreen() {
        root.popToRootViewController(animated: true)
        enableAuthButton()
    }
    
    private func enableAuthButton() {
        (root.viewControllers.first as? IntroViewController)?
            .enableIntroButton()
        (root.viewControllers.first as? GDSInformationViewController)?
            .resetPrimaryButton()
    }
}

extension LoginCoordinator: ParentCoordinator {
    func didRegainFocus(fromChild child: ChildCoordinator?) {
        switch child {
        case is EnrolmentCoordinator:
            finish()
        default:
            break
        }
    }
}
