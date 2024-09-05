import Coordination
import Logging
import SecureStore
import UIKit

protocol AppQualifyingServiceDelegate: AnyObject {
    func didChangeAppInfoState(state: AppInformationState)
    func didChangeUserState(state: AppLocalAuthState)
}

final class QualifyingCoordinator: NSObject,
                                   ParentCoordinator,
                                   AppQualifyingServiceDelegate {
    private let windowManager: WindowManagement
    var childCoordinators = [ChildCoordinator]()
    private let analyticsCenter: AnalyticsCentral
    private var appQualifyingService: QualifyingService
    private let sessionManager: SessionManager
    
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
        appQualifyingService.delegate = self
        windowManager.displayUnlockWindow(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
            Task {
                await appQualifyingService.evaluateUser()
            }
        }
    }
    
    func didChangeAppInfoState(state: AppInformationState) {
        switch state {
        case .appConfirmed:
            // End loading state and enable button
            windowManager.unlockScreenFinishLoading()
        case .appUnavailable:
            // TODO: Display app unavailable screen
            // let appUnavailableScreen = AppUnavailableViewController(viewModel AppUnavailableViewModel())
            // windowManager.appWindow.rootViewController = appUnavailableScreen
            // windowManager.appWindow.makeKeyAndVisible()
            // windowManager.hideUnlockWindow()
            return
        case .appUnconfirmed:
            return
        case .appOffline:
            // Error screen for app offline and no cached data
            return
        }
    }
    
    @MainActor
    func didChangeUserState(state: AppLocalAuthState) {
        switch state {
        case .userConfirmed, .userUnconfirmed:
            Task { @MainActor in
                let tabController = UITabBarController()
                let coordinator = MainCoordinator(windowManager: windowManager,
                                                  root: tabController,
                                                  analyticsCenter: analyticsCenter,
                                                  sessionManager: sessionManager)
                windowManager.appWindow.rootViewController = tabController
                windowManager.appWindow.makeKeyAndVisible()
                coordinator.start()
                windowManager.hideUnlockWindow()
            }
        case .userExpired:
            // Launch MainCoordinator with an error which would prompt reauth
            return
        case .userFailed:
            exit(0)
        }
    }
}
