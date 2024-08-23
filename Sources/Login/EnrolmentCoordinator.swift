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
    private var localAuth: LAContexting
    
    init(root: UINavigationController,
         analyticsService: AnalyticsService,
         sessionManager: SessionManager,
         localAuth: LAContexting) {
        self.root = root
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
        self.localAuth = localAuth
    }
    
    func start() {
        if canUseLocalAuth(.deviceOwnerAuthenticationWithBiometrics) {
            showEnrolmentGuidance()
        } else if !canUseLocalAuth(.deviceOwnerAuthentication) {
            showPasscodeInfo()
        } else {
            // Due to a possible Apple bug, .currentBiometricsOrPasscode does not allow creation of private
            // keys in the secure enclave if no biometrics are registered on the device.  Hence the store
            // needs to be recreated with access controls that allow it
            // todo: userStore.refreshStorage(accessControlLevel: .anyBiometricsOrPasscode)
            finish()
        }
    }
    
    private func canUseLocalAuth(_ policy: LAPolicy) -> Bool {
        localAuth.canEvaluatePolicy(policy, error: nil)
    }
    
    private func showEnrolmentGuidance() {
        switch localAuth.biometryType {
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
                    Task { await enrolLocalAuth(reason: "app_faceId_subtitle") }
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
    
    func enrolLocalAuth(reason: String) async {
        do {
            localAuth.localizeAuthPromptStrings()
            if try await localAuth
                .evaluatePolicy(.deviceOwnerAuthentication,
                                localizedReason: GDSLocalisedString(stringLiteral: reason).value) {
                finish()
            } else {
                return
            }
        } catch {
            return
        }
    }
}
