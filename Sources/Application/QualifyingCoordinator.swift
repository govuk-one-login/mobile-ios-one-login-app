import Coordination
import GDSCommon
import Logging
import Networking
import SecureStore
import UIKit

@MainActor
protocol AppQualifyingServiceDelegate: AnyObject {
    func didChangeAppInfoState(state appInfoState: AppInformationState)
    func didChangeUserState(state userState: AppLocalAuthState)
}

/// A type that is responsible for coordinating the user's eligibility to access the main functionality of the app.
///
/// Performs orchestration based on the state of the app to send the user to either:
/// - Login Coordinator: requiring the user to authenticate to enter the app.
/// - Main Coordinator: allowing the user to access the main app functionality (i.e. Wallet)
///
@MainActor
final class QualifyingCoordinator: NSObject,
                                   Coordinator,
                                   AppQualifyingServiceDelegate {

    private let windowManager: WindowManagement
    var childCoordinators = [ChildCoordinator]()

    private let analyticsCenter: AnalyticsCentral
    private var appQualifyingService: QualifyingService
    private let sessionManager: SessionManager
    private let networkClient: NetworkClient
    
    private var loginCoordinator: LoginCoordinator? {
        childCoordinators.first as? LoginCoordinator
    }

    private var mainCoordinator: MainCoordinator? {
        childCoordinators.first as? MainCoordinator
    }

    init(windowManager: WindowManagement,
         analyticsCenter: AnalyticsCentral,
         appQualifyingService: QualifyingService,
         sessionManager: SessionManager,
         networkClient: NetworkClient) {
        self.windowManager = windowManager
        self.appQualifyingService = appQualifyingService
        self.analyticsCenter = analyticsCenter
        self.sessionManager = sessionManager
        self.networkClient = networkClient
        super.init()
        self.appQualifyingService.delegate = self
    }
    
    func start() {
        windowManager.displayUnlockWindow(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
            Task {
                await appQualifyingService.evaluateUser()
            }
        }
        subscribeToNotifications()
    }
    
    func didChangeAppInfoState(state appInfoState: AppInformationState) {
        switch appInfoState {
        case .appConfirmed:
            // End loading state and enable button
            windowManager.unlockScreenFinishLoading()
        case .appOutdated:
            let appUnavailableScreen = GDSInformationViewController(viewModel: UpdateAppViewModel(analyticsService: analyticsCenter.analyticsService))
            windowManager.showWindowWith(appUnavailableScreen)
            windowManager.hideUnlockWindow()
        case .appUnconfirmed:
            return
        case .appInfoError:
            // todo: display generic error screen?
            return
        case .appOffline:
            // todo: display error screen for app offline and no cached data
            return
        }
    }
    
    func didChangeUserState(state userState: AppLocalAuthState) {
        switch userState {
        case .userConfirmed, .userOneTime:
            // Launch MainCoordinator if not present
            launchMainCoordinator()
        case .userUnconfirmed, .userExpired:
            // Launch LoginCoordinator
            launchLoginCoordinator(userState: userState)
        case .userFailed(let error):
            let unableToLoginErrorScreen = ErrorPresenter
                .createUnableToLoginError(errorDescription: error.localizedDescription,
                                          analyticsService: analyticsCenter.analyticsService) {
                    exit(0)
                }
            windowManager.showWindowWith(unableToLoginErrorScreen)
        }
        windowManager.hideUnlockWindow()
    }
    
    func launchLoginCoordinator(userState: AppLocalAuthState) {
        guard loginCoordinator == nil else {
            return
        }
        let loginCoordinator = LoginCoordinator(appWindow: windowManager.appWindow,
                                                root: UINavigationController(),
                                                analyticsCenter: analyticsCenter,
                                                sessionManager: sessionManager,
                                                userState: userState)
        displayChildCoordinator(loginCoordinator)
    }

    func launchMainCoordinator() {
        let mainCoordinator = mainCoordinator ?? MainCoordinator(
            appWindow: windowManager.appWindow,
            root: UITabBarController(),
            analyticsCenter: analyticsCenter,
            networkClient: networkClient,
            sessionManager: sessionManager)

        displayChildCoordinator(mainCoordinator)
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
        // todo: call `openChild` within `ParentCoordinator.swift`
        childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
        coordinator.start()

        // display in window:
        windowManager.showWindowWith(coordinator.root)
    }
}

extension QualifyingCoordinator {
    func subscribeToNotifications() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(startReauth),
                         name: Notification.Name(.startReauth),
                         object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(logOut),
                         name: Notification.Name(.logOut),
                         object: nil)
    }
    
    @objc private func startReauth() {
        launchLoginCoordinator(userState: AppLocalAuthState.userExpired)
    }
    
    @objc private func logOut() {
        launchLoginCoordinator(userState: AppLocalAuthState.userUnconfirmed)
    }
}

extension QualifyingCoordinator: ParentCoordinator {
    func didRegainFocus(fromChild child: ChildCoordinator?) {
        launchMainCoordinator()
    }
}
