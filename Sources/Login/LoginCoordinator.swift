import AppIntegrity
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
    
    private var sessionState: AppSessionState
    private var serverErrorCounter = 0
    
    private var loginTask: Task<Void, Never>? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    init(
        appWindow: UIWindow,
        root: UINavigationController,
        analyticsService: OneLoginAnalyticsService,
        sessionManager: SessionManager,
        networkMonitor: NetworkMonitoring = NetworkMonitor.shared,
        authService: AuthenticationService,
        sessionState: AppSessionState
    ) {
        self.appWindow = appWindow
        self.root = root
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
        self.networkMonitor = networkMonitor
        self.authService = authService
        self.sessionState = sessionState
    }
    
    deinit {
        loginTask?.cancel()
    }
    
    func start() {
        let rootViewController: UIViewController
        
        if sessionState == .expired {
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
            } catch let error as PersistentSessionError {
                handlePersistentSessionError(error)
            } catch let error as LoginErrorV2 {
                handleLoginV2Error(error)
            } catch let error as JWTVerifierError {
                showRecoverableErrorScreen(error)
            } catch let error as FirebaseAppCheckError {
                handleFirebaseAppCheckError(error)
            } catch let error as ClientAssertionError {
                handleClientAssertionError(error)
            } catch let error as ProofOfPossessionError {
                showUnrecoverableErrorScreen(error)
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
    
    func loginCoordinatorDidDisplay() {
        guard analyticsService.analyticsPreferenceStore.hasAcceptedAnalytics == nil,
              root.topViewController is IntroViewController else {
            return
        }
        switch sessionState {
        case .expired, .loggedIn, .failed, .localAuthCancelled:
            return
        case .notLoggedIn:
            openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsService.analyticsPreferenceStore,
                                                   urlOpener: UIApplication.shared))
        case .userLogOut:
            let viewModel = SignOutSuccessfulViewModel { [unowned self] in
                root.dismiss(animated: true) { [unowned self] in
                    openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsService.analyticsPreferenceStore,
                                                           urlOpener: UIApplication.shared))
                }
            }
            let signOutSuccessful = GDSInformationViewController(viewModel: viewModel)
            signOutSuccessful.modalPresentationStyle = .overFullScreen
            root.present(signOutSuccessful, animated: false)
        case .systemLogOut:
            let viewModel = DataDeletedWarningViewModel { [unowned self] in
                root.dismiss(animated: true) { [unowned self] in
                    openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsService.analyticsPreferenceStore,
                                                           urlOpener: UIApplication.shared))
                }
            }
            let signOutSuccessful = GDSErrorScreen(viewModel: viewModel)
            signOutSuccessful.modalPresentationStyle = .overFullScreen
            root.present(signOutSuccessful, animated: false)
        }
    }
    
    func launchEnrolmentCoordinator() {
        openChildInline(EnrolmentCoordinator(root: root,
                                             analyticsService: analyticsService,
                                             sessionManager: sessionManager))
    }
}

extension LoginCoordinator {
    private func handleLoginV2Error(_ error: LoginErrorV2) {
        switch error.reason {
        case .authorizationAccessDenied:
            showDataDeletedWarningScreen()
        case .userCancelled:
            enableAuthButton()
        case .network:
            showNetworkConnectionErrorScreen { [unowned self] in
                returnFromErrorScreen()
            }
        case .authorizationInvalidRequest,
                .authorizationUnauthorizedClient,
                .authorizationUnsupportedResponseType,
                .authorizationInvalidScope,
                .authorizationTemporarilyUnavailable,
                .tokenInvalidRequest,
                .tokenUnauthorizedClient,
                .tokenInvalidScope,
                .tokenInvalidClient,
                .tokenInvalidGrant,
                .tokenUnsupportedGrantType,
                .tokenClientError:
            showUnrecoverableErrorScreen(error)
        case .authorizationUnknownError,
                .tokenUnknownError,
                .safariOpenError:
            showRecoverableErrorScreen(error)
        case .authorizationServerError,
                .generalServerError:
            self.serverErrorCounter += 1
            if serverErrorCounter < 3 {
                showRecoverableErrorScreen(error)
            } else {
                showUnrecoverableErrorScreen(error)
            }
        case .invalidRedirectURL,
                .programCancelled,
                .authorizationClientError,
                .generic:
            showGenericErrorScreen(error)
        }
    }
    
    private func handlePersistentSessionError(_ error: PersistentSessionError) {
        switch error {
        case .sessionMismatch:
            showDataDeletedWarningScreen()
        case .cannotDeleteData(let error):
            showRecoverableErrorScreen(error)
        case .userRemovedLocalAuth,
                .noSessionExists,
                .idTokenNotStored:
            showGenericErrorScreen(error)
        }
    }
    
    private func handleFirebaseAppCheckError(_ error: FirebaseAppCheckError) {
        switch error.errorType {
        case .network:
            showNetworkConnectionErrorScreen { [unowned self] in
                returnFromErrorScreen()
            }
        case .unknown, .generic:
            showRecoverableErrorScreen(error)
        case .invalidConfiguration,
                .keychainAccess,
                .notSupported:
            showUnrecoverableErrorScreen(error)
        }
    }
    
    private func handleClientAssertionError(_ error: ClientAssertionError) {
        switch error.errorType {
        case .invalidPublicKey:
            showUnrecoverableErrorScreen(error)
        case .invalidToken,
                .serverError,
                .cantDecodeClientAssertion:
            showRecoverableErrorScreen(error)
        }
    }
    
    private func showDataDeletedWarningScreen() {
        let viewModel = DataDeletedWarningViewModel { [unowned self] in
            sessionState = .notLoggedIn
            start()
            loginCoordinatorDidDisplay()
        }
        let vc = GDSErrorScreen(viewModel: viewModel)
        root.pushViewController(vc, animated: true)
    }
    
    private func showRecoverableErrorScreen(_ error: Error) {
        let viewModel = RecoverableLoginErrorViewModel(
            analyticsService: analyticsService,
            errorDescription: error.localizedDescription
        ) { [unowned self] in
            returnFromErrorScreen()
        }
        let unableToLoginErrorScreen = GDSErrorScreen(viewModel: viewModel)
        root.pushViewController(unableToLoginErrorScreen, animated: true)
    }
    
    private func showUnrecoverableErrorScreen(_ error: Error) {
        let viewModel = UnrecoverableLoginErrorViewModel(
            analyticsService: analyticsService,
            errorDescription: error.localizedDescription
        )
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
        let viewModel = GenericErrorViewModel(
            analyticsService: analyticsService,
            errorDescription: error.localizedDescription
        ) { [unowned self] in
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
