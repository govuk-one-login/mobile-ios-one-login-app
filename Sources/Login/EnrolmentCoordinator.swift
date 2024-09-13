import Coordination
import GDSCommon
import LocalAuthentication
import Logging
import UIKit

final class EnrolmentCoordinator: NSObject,
                                  ChildCoordinator,
                                  NavigationCoordinator {
    let root: UINavigationController
    weak var parentCoordinator: ParentCoordinator?
    private let analyticsService: AnalyticsService
    private let sessionManager: SessionManager
    
    init(root: UINavigationController,
         analyticsService: AnalyticsService,
         sessionManager: SessionManager) {
        self.root = root
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
    }
    
    func start() {
        switch sessionManager.localAuthentication.type {
        case .touchID:
            let touchIDEnrollmentScreen = OnboardingViewControllerFactory
                .createTouchIDEnrollmentScreen(analyticsService: analyticsService) { [unowned self] in
                    saveSession()
                } secondaryButtonAction: { [unowned self] in
                    completeEnrolment()
                }
            root.pushViewController(touchIDEnrollmentScreen, animated: true)
        case .faceID:
            let faceIDEnrollmentScreen = OnboardingViewControllerFactory
                .createFaceIDEnrollmentScreen(analyticsService: analyticsService) { [unowned self] in
                    saveSession()
                } secondaryButtonAction: { [unowned self] in
                    completeEnrolment()
                }
            root.pushViewController(faceIDEnrollmentScreen, animated: true)
        case .passcodeOnly:
            showPasscodeInfo()
        case .none:
            completeEnrolment()
        }
    }

    private func saveSession() {
        Task {
            try await sessionManager.saveSession()
            completeEnrolment()
        }
    }

    private func completeEnrolment() {
        NotificationCenter.default.post(name: .enrolmentComplete)
        finish()
    }

    private func showPasscodeInfo() {
        let passcodeInformationScreen = OnboardingViewControllerFactory
            .createPasscodeInformationScreen(analyticsService: analyticsService) { [unowned self] in
                saveSession()
            }
        root.pushViewController(passcodeInformationScreen, animated: true)
    }
}
