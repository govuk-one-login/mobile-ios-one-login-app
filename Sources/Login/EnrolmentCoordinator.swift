import Coordination
import GDSCommon
import LocalAuthenticationWrapper
import UIKit

final class EnrolmentCoordinator: NSObject,
                                  ChildCoordinator,
                                  NavigationCoordinator {
    let root: UINavigationController
    weak var parentCoordinator: ParentCoordinator?
    private let analyticsService: OneLoginAnalyticsService
    private let localAuthContext: LocalAuthWrap
    private let sessionManager: SessionManager
    
    init(root: UINavigationController,
         analyticsService: OneLoginAnalyticsService,
         localAuthContext: LocalAuthWrap = LocalAuthenticationWrapper(localAuthStrings: .oneLogin),
         sessionManager: SessionManager) {
        self.root = root
        self.analyticsService = analyticsService
        self.localAuthContext = localAuthContext
        self.sessionManager = sessionManager
    }
    
    func start() {
        do {
            switch try localAuthContext.type {
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
            case .passcode:
                saveSession()
            case .none:
                completeEnrolment()
            }
        } catch LocalAuthenticationWrapperError.biometricsUnavailable {
            completeEnrolment()
        } catch {
            preconditionFailure()
        }
    }
    
    private func saveSession() {
        #if targetEnvironment(simulator)
        if sessionManager is PersistentSessionManager {
            // UI tests or running on simulator
            completeEnrolment()
            return
        }
        #endif
        Task {
            // Unit tests or running on device
            do {
                guard try await localAuthContext.promptForPermission() else {
                    return
                }
                do {
                    try sessionManager.saveSession()
                    completeEnrolment()
                } catch LocalAuthenticationWrapperError.cancelled {
                    return
                } catch {
                    analyticsService.logCrash(error)
                }
            }
        }
    }
    
    private func completeEnrolment() {
        NotificationCenter.default.post(name: .enrolmentComplete)
        finish()
    }
}
