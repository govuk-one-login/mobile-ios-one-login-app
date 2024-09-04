import Coordination
import Logging
import SecureStore
import UIKit

protocol AppQualifyingServiceDelegate: AnyObject {
    func didChangeState(state: AppInformationState)
}

final class QualifyingCoordinator: NSObject,
                                   ParentCoordinator,
                                   AppQualifyingServiceDelegate {
    private let windowManager: WindowManagement
    var childCoordinators = [ChildCoordinator]()
    private let analyticsCenter: AnalyticsCentral
    private let appQualifyingService: QualifyingService
    private let sessionManager: SessionManager
    
    init(windowManager: WindowManagement,
         appQualifyingService: QualifyingService = AppQualifyingService(),
         analyticsCenter: AnalyticsCentral,
         sessionManager: SessionManager) {
        self.windowManager = windowManager
        self.appQualifyingService = appQualifyingService
        self.analyticsCenter = analyticsCenter
        self.sessionManager = sessionManager
        self.appQualifyingService.delegate = self
    }
    
    func start() {
        windowManager.displayUnlockWindow(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
            evaluateUser()
        }
        evaluateUser()
    }
    
    func didChangeState(state: AppInformationState) {
        switch state {
        case .offline:
            return
        case .unconfirmed:
            return
        case .unavailable:
            // TODO: Display app unavailable screen
            // let appUnavailableScreen = AppUnavailableViewController(viewModel AppUnavailableViewModel())
            // windowManager.appWindow.rootViewController = appUnavailableScreen
            // windowManager.appWindow.makeKeyAndVisible()
            // windowManager.hideUnlockWindow()
            return
        case .onlineConfirmed(app: let app):
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
    }
    
    func evaluateUser() {
        guard sessionManager.expiryDate != nil else {
            return
        }
        
        guard sessionManager.isSessionValid else {
            return
        }
        
        Task {
            await MainActor.run {
                do {
                    try sessionManager.resumeSession()
                    //                    updateToken()
                    windowManager.hideUnlockWindow()
                } catch {
                    switch error {
                    case is JWTVerifierError,
                        SecureStoreError.unableToRetrieveFromUserDefaults,
                        SecureStoreError.cantInitialiseData,
                        SecureStoreError.cantRetrieveKey:
                        return
                        //                        fullLogin(loginError: error)
                    default:
                        print("Token retrival error: \(error)")
                    }
                }
            }
        }
    }
}
