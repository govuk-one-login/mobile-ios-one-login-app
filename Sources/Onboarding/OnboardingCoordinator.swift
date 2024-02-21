import Coordination
import LocalAuthentication
import Logging
import SecureStore
import UIKit

final class OnboardingCoordinator: NSObject,
                                   ChildCoordinator,
                                   NavigationCoordinator {
    let root: UINavigationController
    var parentCoordinator: ParentCoordinator?
    let localAuth: LAContexting
    var secureStore: SecureStorable?
    let analyticsService: AnalyticsService
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    let tokenHolder: TokenHolder
    
    init(root: UINavigationController,
         analyticsService: AnalyticsService,
         localAuth: LAContexting = LAContext(),
         tokenHolder: TokenHolder) {
        self.root = root
        self.analyticsService = analyticsService
        self.localAuth = localAuth
        self.tokenHolder = tokenHolder
    }
    
    func start() {
        root.isNavigationBarHidden = true
        if canUseLocalAuth(.deviceOwnerAuthenticationWithBiometrics) {
            showEnrolmentGuidance()
        } else if !canUseLocalAuth(.deviceOwnerAuthentication) {
            showPasscodeInfo()
        } else {
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
                    storeAcccessToken()
                    finish()
                } secondaryButtonAction: { [unowned self] in
                    finish()
                }
            root.pushViewController(touchIDEnrollmentScreen, animated: true)
        case .faceID:
            let faceIDEnrollmentScreen = viewControllerFactory
                .createFaceIDEnrollmentScreen(analyticsService: analyticsService) { [unowned self] in
                    Task { await enrolLocalAuth(reason: " ") }
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
    
    private func storeAcccessToken() {
        guard let tokenResponse = tokenHolder.tokenResponse else { return }
        secureStore = SecureStoreService(configuration: .init(id: "tokens", accessControlLevel: .anyBiometricsOrPasscode))
        do {
            try secureStore?.saveItem(item: tokenResponse.accessToken, itemName: "accessToken")
        } catch {
            print("error")
        }
    }
    
    private func enrolLocalAuth(reason: String) async {
        do {
            if try await localAuth
                .evaluatePolicy(.deviceOwnerAuthentication, localizedReason: NSLocalizedString(reason, comment: "")) {
                finish()
            } else {
                return
            }
        } catch {
            return
        }
    }
}
