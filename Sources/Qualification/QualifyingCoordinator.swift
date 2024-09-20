import Coordination
import GDSCommon
import Logging
import Networking
import SecureStore
import UIKit

/// A type that is responsible for coordinating the user's eligibility to access the main functionality of the app.
///
/// Performs orchestration based on the state of the app to send the user to either:
/// - Login Coordinator: requiring the user to authenticate to enter the app.
/// - Main Coordinator: allowing the user to access the main app functionality (i.e. Wallet)
///
@MainActor
final class QualifyingCoordinator: NSObject,
                                   ParentCoordinator,
                                   AppQualifyingServiceDelegate {
    private let window: UIWindow
    var childCoordinators = [ChildCoordinator]()

    private let analyticsCenter: AnalyticsCentral
    private let appQualifyingService: QualifyingService
    private let sessionManager: SessionManager
    private let networkClient: NetworkClient

    private var loginCoordinator: LoginCoordinator? {
        childCoordinators.firstInstanceOf(LoginCoordinator.self)
    }

    private var mainCoordinator: MainCoordinator? {
        childCoordinators.firstInstanceOf(MainCoordinator.self)
    }

    private lazy var unlockViewController: UnlockScreenViewController = {
        let viewModel = UnlockScreenViewModel(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
            Task {
                await appQualifyingService.evaluateUser()
            }
        }
        return UnlockScreenViewController(viewModel: viewModel)
    }()

    init(window: UIWindow,
         analyticsCenter: AnalyticsCentral,
         appQualifyingService: QualifyingService,
         sessionManager: SessionManager,
         networkClient: NetworkClient) {
        self.window = window
        self.appQualifyingService = appQualifyingService
        self.analyticsCenter = analyticsCenter
        self.sessionManager = sessionManager
        self.networkClient = networkClient
        super.init()
        self.appQualifyingService.delegate = self
    }
    
    func start() {
        lock()
    }

    func lock() {
        displayViewController(unlockViewController)
    }

    func didChangeAppInfoState(state appInfoState: AppInformationState) {
        switch appInfoState {
        case .appUnconfirmed:
            lock()
        case .appConfirmed:
            // End loading state and enable button
            unlockViewController.isLoading = false
        case .appOutdated:
            let appUnavailableScreen = GDSInformationViewController(
                viewModel: UpdateAppViewModel(analyticsService: analyticsCenter.analyticsService)
            )
            displayViewController(appUnavailableScreen)
        case .appInfoError:
            // TODO: DCMAW-9866 | display generic error screen?
            return
        case .appOffline:
            // TODO: DCMAW-9866 |display error sc(oreen for app offline and no cached data
            return
        }
    }
    
    func didChangeUserState(state userState: AppLocalAuthState) {
        switch userState {
        case .userConfirmed:
            launchMainCoordinator()
        case .userUnconfirmed, .userExpired:
            launchLoginCoordinator(userState: userState)
        case .userFailed(let error):
            let unableToLoginErrorScreen = ErrorPresenter
                .createUnableToLoginError(errorDescription: error.localizedDescription,
                                          analyticsService: analyticsCenter.analyticsService) {
                    fatalError("We were unable to resume the session, there's not much we can do to help the user")
                }
            displayViewController(unableToLoginErrorScreen)
        }
    }
    
    func launchLoginCoordinator(userState: AppLocalAuthState) {
        if let loginCoordinator = loginCoordinator {
            displayViewController(loginCoordinator.root)
        } else {
            let loginCoordinator = LoginCoordinator(
                appWindow: window,
                root: UINavigationController(),
                analyticsCenter: analyticsCenter,
                sessionManager: sessionManager,
                isExpiredUser: userState == .userExpired
            )
            displayChildCoordinator(loginCoordinator)
        }
    }
    
    func launchMainCoordinator() {
        if let mainCoordinator {
            displayViewController(mainCoordinator.root)
        } else {
            let mainCoordinator = MainCoordinator(
                appWindow: window,
                root: UITabBarController(),
                analyticsCenter: analyticsCenter,
                networkClient: networkClient,
                sessionManager: sessionManager)
            displayChildCoordinator(mainCoordinator)
        }
    }

    func handleUniversalLink(_ url: URL) {
        // Ensure qualifying checks have completed
        switch UniversalLinkQualifier.qualifyOneLoginUniversalLink(url) {
        case .login:
            loginCoordinator?.handleUniversalLink(url)
        case .wallet:
            mainCoordinator?.handleUniversalLink(url)
        case .unknown:
            return
        }
    }

    private func displayChildCoordinator(_ coordinator: any ChildCoordinator & AnyCoordinator) {
        // display in window:
        displayViewController(coordinator.root)

        // TODO: DCMAW-9866 | call `openChild` within `ParentCoordinator.swift`
        childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
        coordinator.start()
    }

    private func displayViewController(_ viewController: UIViewController) {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
