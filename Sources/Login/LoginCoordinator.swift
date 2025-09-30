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
    private let sessionManager: SessionManager
    private let networkMonitor: NetworkMonitoring
    private let authService: AuthenticationService
    
    private var authState: AppLocalAuthState
    private var serverErrorCounter = 0
    
    private var loginTask: Task<Void, Never>? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    init(appWindow: UIWindow,
         root: UINavigationController,
         analyticsService: OneLoginAnalyticsService,
         sessionManager: SessionManager,
         networkMonitor: NetworkMonitoring = NetworkMonitor.shared,
         authService: AuthenticationService,
         authState: AppLocalAuthState) {
        self.appWindow = appWindow
        self.root = root
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
        self.networkMonitor = networkMonitor
        self.authService = authService
        self.authState = authState
    }
    
    deinit {
        loginTask?.cancel()
    }
    
    func start() {
        let rootViewController: UIViewController
        
        if authState == .expired {
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
            } catch let error as LoginErrorV2 where error.reason == .authorizationUnknownError,
                    let error as LoginErrorV2 where error.reason == .tokenUnknownError,
                    let error as LoginErrorV2 where error.reason == .safariOpenError {
                showRecoverableErrorScreen(error)
            } catch let error as LoginErrorV2 where error.reason == .authorizationServerError,
                    let error as LoginErrorV2 where error.reason == .generalServerError {
                self.serverErrorCounter += 1
                if serverErrorCounter < 3 {
                    showRecoverableErrorScreen(error)
                } else {
                    showUnrecoverableErrorScreen(error)
                }
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
        self.serverErrorCounter = 0
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
    
    func promptForAnalyticsPermissions() {
        guard analyticsService.analyticsPreferenceStore.hasAcceptedAnalytics == nil,
              root.topViewController is IntroViewController else {
            return
        }
        if authState == .userLogOut {
            let viewModel = SignOutSuccessfulViewModel { [unowned self] in
                root.dismiss(animated: true) { [unowned self] in
                    openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsService.analyticsPreferenceStore,
                                                           urlOpener: UIApplication.shared))
                }
            }
            let signOutSuccessful = GDSInformationViewController(viewModel: viewModel)
            signOutSuccessful.modalPresentationStyle = .overFullScreen
            root.present(signOutSuccessful, animated: false)
        } else {
            openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsService.analyticsPreferenceStore,
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
            authState = .notLoggedIn
            start()
            promptForAnalyticsPermissions()
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
