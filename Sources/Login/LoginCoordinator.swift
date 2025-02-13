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
    
    private let analyticsCenter: AnalyticsCentral
    private let sessionManager: SessionManager
    private let networkMonitor: NetworkMonitoring
    private let authService: AuthenticationService
    private var isExpiredUser: Bool
    
    private var loginTask: Task<Void, Never>? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    private var introViewController: IntroViewController? {
        root.viewControllers.first as? IntroViewController
    }
    
    init(appWindow: UIWindow,
         root: UINavigationController,
         analyticsCenter: AnalyticsCentral,
         sessionManager: SessionManager,
         networkMonitor: NetworkMonitoring = NetworkMonitor.shared,
         authService: AuthenticationService,
         isExpiredUser: Bool) {
        self.appWindow = appWindow
        self.root = root
        self.analyticsCenter = analyticsCenter
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
                showUnableToLoginErrorScreen(error)
            } catch let error as LoginError where error == .userCancelled {
                introViewController?.enableIntroButton()
            } catch let error as LoginError where error == .network {
                showNetworkConnectionErrorScreen { [unowned self] in
                    returnFromErrorScreen()
                }
            } catch let error as LoginError where error == .non200,
                    let error as LoginError where error == .invalidRequest,
                    let error as LoginError where error == .clientError,
                    let error as LoginError where error == .serverError {
                showUnableToLoginErrorScreen(error)
            } catch let error as JWTVerifierError {
                showUnableToLoginErrorScreen(error)
            } catch {
                showGenericErrorScreen(error)
            }
        }
    }
    
    private func triggerAuthFlow() async throws {
        try await authService.start()
        guard sessionManager.isReturningUser else {
            launchEnrolmentCoordinator()
            return
        }
        finish()
    }
    
    func handleUniversalLink(_ url: URL) {
        let loginLoadingScreen = GDSLoadingViewController(
            viewModel: LoginLoadingViewModel(
                analyticsService: analyticsCenter.analyticsService
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
        if analyticsCenter.analyticsPermissionsNotSet, root.topViewController is IntroViewController {
            openChildModally(OnboardingCoordinator(analyticsPreferenceStore: analyticsCenter.analyticsPreferenceStore,
                                                   urlOpener: UIApplication.shared))
        }
    }
        
    func launchEnrolmentCoordinator() {
        openChildInline(EnrolmentCoordinator(root: root,
                                             analyticsService: analyticsCenter.analyticsService,
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
        let vc = GDSErrorViewController(viewModel: viewModel)
        root.pushViewController(vc, animated: true)
    }
    
    private func showUnableToLoginErrorScreen(_ error: Error) {
        let viewModel = UnableToLoginErrorViewModel(analyticsService: analyticsCenter.analyticsService,
                                                    errorDescription: error.localizedDescription) { [unowned self] in
            returnFromErrorScreen()
        }
        let unableToLoginErrorScreen = GDSErrorViewController(viewModel: viewModel)
        root.pushViewController(unableToLoginErrorScreen, animated: true)
    }
    
    private func showNetworkConnectionErrorScreen(action: @escaping () -> Void) {
        let viewModel = NetworkConnectionErrorViewModel(analyticsService: analyticsCenter.analyticsService) {
            action()
        }
        let networkErrorScreen = GDSErrorViewController(viewModel: viewModel)
        root.pushViewController(networkErrorScreen, animated: true)
    }
    
    private func showGenericErrorScreen(_ error: Error) {
        let viewModel = GenericErrorViewModel(analyticsService: analyticsCenter.analyticsService,
                                              errorDescription: error.localizedDescription) { [unowned self] in
            returnFromErrorScreen()
        }
        let genericErrorScreen = GDSErrorViewController(viewModel: viewModel)
        root.pushViewController(genericErrorScreen, animated: true)
    }
    
    private func returnFromErrorScreen() {
        root.popToRootViewController(animated: true)
        introViewController?.enableIntroButton()
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
