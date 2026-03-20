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
    
    private var sessionState: AppSessionState?
    private var serviceState: RemoteServiceState?

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
        sessionState: AppSessionState?,
        serviceState: RemoteServiceState?
    ) {
        self.appWindow = appWindow
        self.root = root
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
        self.networkMonitor = networkMonitor
        self.authService = authService
        self.sessionState = sessionState
        self.serviceState = serviceState
    }
    
    deinit {
        loginTask?.cancel()
    }
    
    func start() {
        let rootViewController: UIViewController
        
        if sessionState == .expired || serviceState == .accountIntervention || serviceState == .reauthenticationRequired {
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
            } catch let error as LoginError {
                handleLoginError(error)
            } catch let error as JWTVerifierError {
                showRecoverableErrorScreen(error)
            } catch is FirebaseAppCheckError, is ClientAssertionError, is ProofOfPossessionError {
                showAppIntegrityErrorScreen()
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
        switch (sessionState, serviceState) {
        case (.notLoggedIn, _):
            guard analyticsService.analyticsPreferenceStore.hasAcceptedAnalytics == nil,
                  root.topViewController is IntroViewController else {
                return
            }
            
            openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsService.analyticsPreferenceStore,
                                                   urlOpener: UIApplication.shared))
        case (.userLogOut, _):
            let viewModel = SignOutSuccessfulViewModel { [unowned self] in
                root.dismiss(animated: true) { [unowned self] in
                    openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsService.analyticsPreferenceStore,
                                                           urlOpener: UIApplication.shared))
                }
            }
            let signOutSuccessful = GDSInformationViewController(viewModel: viewModel)
            signOutSuccessful.modalPresentationStyle = .overFullScreen
            root.present(signOutSuccessful, animated: false)
        case (.systemLogOut, _):
            let viewModel = DataDeletedWarningViewModel { [unowned self] in
                root.dismiss(animated: true) { [unowned self] in
                    openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsService.analyticsPreferenceStore,
                                                           urlOpener: UIApplication.shared))
                }
            }
            let signOutSuccessful = GDSErrorScreen(viewModel: viewModel)
            signOutSuccessful.modalPresentationStyle = .overFullScreen
            root.present(signOutSuccessful, animated: false)
        case (_, .accountIntervention):
            serviceState = .accountIntervention
        case (_, .reauthenticationRequired):
            serviceState = .reauthenticationRequired
        case (_, _):
            return
        }
    }
    
    func launchEnrolmentCoordinator() {
        openChildInline(EnrolmentCoordinator(root: root,
                                             analyticsService: analyticsService,
                                             sessionManager: sessionManager))
    }
}

extension LoginCoordinator {
    private func handleLoginError(_ error: LoginError) {
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
        switch error.kind {
        case .sessionMismatch:
            showDataDeletedWarningScreen()
        case .cannotDeleteData:
            showRecoverableErrorScreen(error)
        // These 3 cases are never thrown in startAuthSession
        case .userRemovedLocalAuth,
                .noSessionExists,
                .idTokenNotStored:
            showGenericErrorScreen(error)
        }
    }
    
    private func showDataDeletedWarningScreen() {
        let viewModel = DataDeletedWarningViewModel { [unowned self] in
            serviceState = nil
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
    
    private func showAppIntegrityErrorScreen() {
        let viewModel = AppIntegrityErrorViewModel(
            analyticsService: analyticsService
        )
        let vc = GDSErrorScreen(viewModel: viewModel)
        root.pushViewController(vc, animated: true)
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
