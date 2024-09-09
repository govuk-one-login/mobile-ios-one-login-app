import Coordination
import GDSCommon
import Logging
import Networking
import SecureStore
import UIKit

protocol AppQualifyingServiceDelegate: AnyObject {
    func didChangeAppInfoState(state appInfoState: AppInformationState)
    func didChangeUserState(state userState: AppLocalAuthState)
}

final class QualifyingCoordinator: NSObject,
                                   NavigationCoordinator,
                                   AppQualifyingServiceDelegate {
    private let windowManager: WindowManagement
    let root = UINavigationController()
    var childCoordinators = [ChildCoordinator]()
    private let analyticsCenter: AnalyticsCentral
    private var appQualifyingService: QualifyingService
    private let sessionManager: SessionManager
    private let networkClient: NetworkClient
    
    private weak var loginCoordinator: LoginCoordinator?
    private weak var mainCoordinator: MainCoordinator?
    
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
            // Generic error screen?
            return
        case .appOffline:
            // Error screen for app offline and no cached data
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
        Task { @MainActor in
            let loginCoordinator = LoginCoordinator(appWindow: windowManager.appWindow,
                                                    root: root,
                                                    analyticsCenter: analyticsCenter,
                                                    sessionManager: sessionManager,
                                                    userState: userState)
            windowManager.showWindowWith(loginCoordinator.root)
            openChildInline(loginCoordinator)
            self.loginCoordinator = loginCoordinator
            mainCoordinator = nil
        }
    }
    
    func launchMainCoordinator() {
        guard mainCoordinator == nil else {
            return
        }
        Task { @MainActor in
            let mainCoordinator = MainCoordinator(appWindow: windowManager.appWindow,
                                                  root: UITabBarController(),
                                                  analyticsCenter: analyticsCenter,
                                                  networkClient: networkClient,
                                                  sessionManager: sessionManager)
            windowManager.showWindowWith(mainCoordinator.root)
            mainCoordinator.start()
            self.mainCoordinator = mainCoordinator
            loginCoordinator = nil
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
