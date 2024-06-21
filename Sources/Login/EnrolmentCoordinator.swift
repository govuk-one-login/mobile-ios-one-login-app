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
    let analyticsService: AnalyticsService
    let userStore: UserStorable
    var localAuth: LAContexting
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    let tokenHolder: TokenHolder
    
    init(root: UINavigationController,
         analyticsService: AnalyticsService,
         userStore: UserStorable,
         localAuth: LAContexting,
         tokenHolder: TokenHolder) {
        self.root = root
        self.analyticsService = analyticsService
        self.userStore = userStore
        self.localAuth = localAuth
        self.tokenHolder = tokenHolder
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
            userStore.refreshStorage(accessControlLevel: .anyBiometricsOrPasscode)
            storeAccessTokenInfo()
            finish()
        }
    }
    
    private func canUseLocalAuth(_ policy: LAPolicy) -> Bool {
        localAuth.canEvaluatePolicy(policy, error: nil)
    }
    
    private func showEnrolmentGuidance() {
        switch localAuth.biometryType {
        case .touchID:
            let touchIDEnrollmentScreen = viewControllerFactory
                .createTouchIDEnrollmentScreen(analyticsService: analyticsService) { [unowned self] in
                    storeAccessTokenInfo()
                    finish()
                } secondaryButtonAction: { [unowned self] in
                    finish()
                }
            root.pushViewController(touchIDEnrollmentScreen, animated: true)
        case .faceID:
            let faceIDEnrollmentScreen = viewControllerFactory
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
        let passcodeInformationScreen = viewControllerFactory
            .createPasscodeInformationScreen(analyticsService: analyticsService) { [unowned self] in
                finish()
            }
        root.pushViewController(passcodeInformationScreen, animated: true)
    }
    
    private func storeAccessTokenInfo() {
        guard let tokenResponse = tokenHolder.tokenResponse else { return }
        do {
            try userStore.storeTokenInfo(tokenResponse: tokenResponse)
        } catch {
            print("Storing Token Info error: \(error)")
        }
    }
    
    func enrolLocalAuth(reason: String) async {
        do {
            localAuth.localizeAuthPromptStrings()
            if try await localAuth
                .evaluatePolicy(.deviceOwnerAuthentication,
                                localizedReason: GDSLocalisedString(stringLiteral: reason).value) {
                storeAccessTokenInfo()
                finish()
            } else {
                return
            }
        } catch {
            return
        }
    }
}
