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
                    completeEnrolment()
                } secondaryButtonAction: { [unowned self] in
                    finish()
                }
            root.pushViewController(touchIDEnrollmentScreen, animated: true)
        case .faceID:
            let faceIDEnrollmentScreen = OnboardingViewControllerFactory
                .createFaceIDEnrollmentScreen(analyticsService: analyticsService) { [unowned self] in
                    completeEnrolment()
                } secondaryButtonAction: { [unowned self] in
                    finish()
                }
            root.pushViewController(faceIDEnrollmentScreen, animated: true)
        case .passcodeOnly:
            showPasscodeInfo()
        case .none:
            finish()
        }
    }

    private func completeEnrolment() {
        Task {
            do {
                try await sessionManager.saveSession()
                finish()
            } catch {
                // TODO: DCMAW-9700 - handle errors thrown here:
                fatalError("Handle these errors")
            }
        }
    }

    private func showPasscodeInfo() {
        let passcodeInformationScreen = OnboardingViewControllerFactory
            .createPasscodeInformationScreen(analyticsService: analyticsService) { [unowned self] in
                completeEnrolment()
            }
        root.pushViewController(passcodeInformationScreen, animated: true)
    }
}
