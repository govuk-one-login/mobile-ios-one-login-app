import Coordination
import GDSCommon
import Logging
import SecureStore
import UIKit

protocol AppQualifyingServiceDelegate: AnyObject {
    func didChangeAppInfoState(state appInfoState: AppInformationState)
    func didChangeUserState(state userState: AppLocalAuthState)
}

final class QualifyingCoordinator: NSObject,
                                   ParentCoordinator,
                                   AppQualifyingServiceDelegate {
    private let windowManager: WindowManagement
    var childCoordinators = [ChildCoordinator]()
    private let analyticsCenter: AnalyticsCentral
    private var appQualifyingService: QualifyingService
    private let sessionManager: SessionManager
    
    private weak var mainCoordinator: MainCoordinator?
    
    init(windowManager: WindowManagement,
         analyticsCenter: AnalyticsCentral,
         appQualifyingService: QualifyingService,
         sessionManager: SessionManager) {
        self.windowManager = windowManager
        self.appQualifyingService = appQualifyingService
        self.analyticsCenter = analyticsCenter
        self.sessionManager = sessionManager
    }
    
    func start() {
        windowManager.displayUnlockWindow(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
            Task {
                await appQualifyingService.evaluateUser()
            }
        }
    }
    
    func didChangeAppInfoState(state appInfoState: AppInformationState) {
        switch appInfoState {
        case .appConfirmed:
            // End loading state and enable button
            windowManager.unlockScreenFinishLoading()
        case .appOutdated:
            let appUnavailableScreen = GDSInformationViewController(viewModel: UpdateAppViewModel(analyticsService: analyticsCenter.analyticsService))
            windowManager.openAppWith(appUnavailableScreen)
            windowManager.hideUnlockWindow()
        case .appUnconfirmed:
            return
        case .appUnavailable:
            // Generic error screen?
            return
        case .appOffline:
            // Error screen for app offline and no cached data
            return
        }
    }
    
    func didChangeUserState(state userState: AppLocalAuthState) {
        switch userState {
        case .userConfirmed, .userUnconfirmed, .userExpired:
            if let mainCoordinator {
                mainCoordinator.userState = userState
                mainCoordinator.start()
            } else {
                Task { @MainActor in
                    let coordinator = MainCoordinator(windowManager: windowManager,
                                                      root: UITabBarController(),
                                                      analyticsCenter: analyticsCenter,
                                                      sessionManager: sessionManager,
                                                      userState: userState)
                    mainCoordinator = coordinator
                    windowManager.openAppWith(coordinator.root)
                    coordinator.start()
                }
            }
            windowManager.hideUnlockWindow()
        case .userOneTime:
            windowManager.hideUnlockWindow()
        case .userFailed(let error):
            let unableToLoginErrorScreen = ErrorPresenter
                .createUnableToLoginError(errorDescription: error.localizedDescription,
                                          analyticsService: analyticsCenter.analyticsService) {
                    exit(0)
                }
            windowManager.openAppWith(unableToLoginErrorScreen)
            windowManager.hideUnlockWindow()
        }
    }
    
    func handleUniversalLink(_ url: URL) {
        // Ensure qualifying checks have completed
        mainCoordinator?.handleUniversalLink(url)
    }
}
