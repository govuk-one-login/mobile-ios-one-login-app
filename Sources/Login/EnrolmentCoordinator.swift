import Coordination
import GDSCommon
import LocalAuthentication
import Logging
import SecureStore
import UIKit

final class EnrolmentCoordinator: NSObject,
                                  ChildCoordinator,
                                  NavigationCoordinator {
    let root: UINavigationController
    weak var parentCoordinator: ParentCoordinator?
    private let analyticsService: OneLoginAnalyticsService
    private let sessionManager: SessionManager
    
    init(root: UINavigationController,
         analyticsService: OneLoginAnalyticsService,
         sessionManager: SessionManager) {
        self.root = root
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
    }
    
    func start() {
        switch sessionManager.localAuthentication.type {
        case .touchID:
            let viewModel = TouchIDEnrolmentViewModel(analyticsService: analyticsService) { [unowned self] in
                saveSession()
            } secondaryButtonAction: { [unowned self] in
                completeEnrolment()
            }
            let touchIDEnrolmentScreen = GDSInformationViewController(viewModel: viewModel)
            root.pushViewController(touchIDEnrolmentScreen, animated: true)
        case .faceID:
            let viewModel = FaceIDEnrolmentViewModel(analyticsService: analyticsService) { [unowned self] in
                saveSession()
            } secondaryButtonAction: { [unowned self] in
                completeEnrolment()
            }
            let faceIDEnrolmentScreen = GDSInformationViewController(viewModel: viewModel)
            root.pushViewController(faceIDEnrolmentScreen, animated: true)
        case .passcodeOnly:
            saveSession()
        case .none:
            completeEnrolment()
        }
    }

    private func saveSession() {
        Task {
            #if targetEnvironment(simulator)
                if sessionManager is PersistentSessionManager {
                    // UI tests or running on simulator
                    completeEnrolment()
                    return
                }
            #endif
            // Unit tests or running on device
            do {
                try await sessionManager.saveSession()
            } catch let error as SecureStoreError {
                analyticsService.logCrash(error)
            }
            completeEnrolment()
        }
    }

    private func completeEnrolment() {
        NotificationCenter.default.post(name: .enrolmentComplete)
        finish()
    }
}
