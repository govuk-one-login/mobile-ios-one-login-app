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
    private var localAuthManager: LocalAuthManagement
    
    init(root: UINavigationController,
         analyticsService: AnalyticsService,
         sessionManager: SessionManager,
         localAuthManager: LocalAuthManagement) {
        self.root = root
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
        self.localAuthManager = localAuthManager
    }
    
    func start() {
        if localAuthManager.canUseLocalAuth(type: .deviceOwnerAuthenticationWithBiometrics) {
            showEnrolmentGuidance()
        } else if !localAuthManager.canUseLocalAuth(type: .deviceOwnerAuthentication) {
            showPasscodeInfo()
        } else {
            // Due to a possible Apple bug, .currentBiometricsOrPasscode does not allow creation of private
            // keys in the secure enclave if no biometrics are registered on the device.  Hence the store
            // needs to be recreated with access controls that allow it
            // TODO: userStore.refreshStorage(accessControlLevel: .anyBiometricsOrPasscode)
            finish()
        }
    }
    
    private func showEnrolmentGuidance() {
        switch localAuthManager.biometryType {
        case .touchID:
            let touchIDEnrollmentScreen = OnboardingViewControllerFactory
                .createTouchIDEnrollmentScreen(analyticsService: analyticsService) { [unowned self] in
                    finish()
                } secondaryButtonAction: { [unowned self] in
                    finish()
                }
            root.pushViewController(touchIDEnrollmentScreen, animated: true)
        case .faceID:
            let faceIDEnrollmentScreen = OnboardingViewControllerFactory
                .createFaceIDEnrollmentScreen(analyticsService: analyticsService) { [unowned self] in
                    Task {
                        try? await localAuthManager.enrolLocalAuth(reason: "app_faceId_subtitle")
                    }
                } secondaryButtonAction: { [unowned self] in
                    finish()
                }
            root.pushViewController(faceIDEnrollmentScreen, animated: true)
        case .opticID, .none:
            return
        @unknown default:
            return
        }
    }
    
    private func showPasscodeInfo() {
        let passcodeInformationScreen = OnboardingViewControllerFactory
            .createPasscodeInformationScreen(analyticsService: analyticsService) { [unowned self] in
                finish()
            }
        root.pushViewController(passcodeInformationScreen, animated: true)
    }
}
