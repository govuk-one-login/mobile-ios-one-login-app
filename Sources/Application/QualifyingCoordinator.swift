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
         appQualifyingService: QualifyingService,
         analyticsCenter: AnalyticsCentral,
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
        case .appUnavailable:
            // TODO: Display app unavailable screen
            let appUnavailableScreen = GDSInformationViewController(viewModel: UpdateAppViewModel(analyticsService: analyticsCenter.analyticsService))
            windowManager.startAppWith(appUnavailableScreen)
            windowManager.hideUnlockWindow()
        case .appUnconfirmed:
            return
        case .appOffline:
            // Error screen for app offline and no cached data
            return
        }
    }
    
    func didChangeUserState(state userState: AppLocalAuthState) {
        switch userState {
        case .userConfirmed, .userUnconfirmed:
            Task { @MainActor in
                let coordinator = MainCoordinator(windowManager: windowManager,
                                                  root: UITabBarController(),
                                                  analyticsCenter: analyticsCenter,
                                                  sessionManager: sessionManager)
                windowManager.startAppWith(coordinator.root)
                coordinator.start()
                windowManager.hideUnlockWindow()
            }
        case .userExpired:
            // Launch MainCoordinator with an error which would prompt reauth
            return
        case .userOneTime:
            windowManager.hideUnlockWindow()
        case .userFailed:
            exit(0)
        }
    }
    
    func handleUniversalLink(_ url: URL) {
        // Ensure qualifying checks have completed
        mainCoordinator?.handleUniversalLink(url)
    }
}
