import Coordination
import GDSCommon
import LocalAuthenticationWrapper
import SecureStore
import UIKit

@MainActor
final class OneLoginLocalAuthManager {
    private weak var coordinator: ChildCoordinator?
    private let root: UINavigationController
    private let analyticsService: OneLoginAnalyticsService
    private let localAuthContext: LocalAuthWrap
    private let sessionManager: SessionManager
    
    init(coordinator: ChildCoordinator? = nil,
         navigationController root: UINavigationController,
         analyticsService: OneLoginAnalyticsService,
         localAuthContext: LocalAuthWrap = LocalAuthenticationWrapper(localAuthStrings: .oneLogin),
         sessionManager: SessionManager) {
        self.coordinator = coordinator
        self.root = root
        self.analyticsService = analyticsService
        self.localAuthContext = localAuthContext
        self.sessionManager = sessionManager
    }
    
    func startOneLoginEnrolmentFlow() {
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
            case .none:
                saveSession()
            case .passcode:
                completeEnrolment()
            }
        } catch {
            preconditionFailure()
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
                guard try await localAuthContext.promptForPermission() else {
                    return
                }
                try await sessionManager.saveSession()
                completeEnrolment()
            } catch LocalAuthenticationWrapperError.cancelled {
                return
            } catch {
                analyticsService.logCrash(error)
            }
        }
    }
    
    private func completeEnrolment() {
        NotificationCenter.default.post(name: .enrolmentComplete)
        coordinator?.finish()
    }
}

extension LocalAuthPromptStrings {
    static var oneLogin: LocalAuthPromptStrings {
        LocalAuthPromptStrings(
            faceIdSubtitle: GDSLocalisedString(
                stringLiteral: "app_faceId_subtitle"
            ).value,
            touchIdSubtitle: GDSLocalisedString(
                stringLiteral: "app_touchId_subtitle"
            ).value,
            passcodeButton: GDSLocalisedString(
                stringLiteral: "app_enterPasscodeButton"
            ).value,
            cancelButton: GDSLocalisedString(
                stringLiteral: "app_cancelButton"
            ).value
        )
    }
}
