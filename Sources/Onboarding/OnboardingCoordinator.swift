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
    let secureStore: SecureStorable
    let analyticsService: AnalyticsService
    let tokenHolder: TokenHolder
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    
    init(root: UINavigationController,
         localAuth: LAContexting = LAContext(),
         secureStore: SecureStorable = SecureStoreService(configuration: .init(id: "oneLoginTokens",
                                                                               accessControlLevel: .anyBiometricsOrPasscode)),
         analyticsService: AnalyticsService,
         tokenHolder: TokenHolder) {
        self.root = root
        self.localAuth = localAuth
        self.secureStore = secureStore
        self.analyticsService = analyticsService
        self.tokenHolder = tokenHolder
    }
    
    func start() {
        root.isNavigationBarHidden = true
        if canUseLocalAuth(.deviceOwnerAuthenticationWithBiometrics) {
            showEnrolmentGuidance()
        } else if !canUseLocalAuth(.deviceOwnerAuthentication) {
            showPasscodeInfo()
        } else {
            storeAccessToken()
            finish()
        }
        UserDefaults.standard.set(true, forKey: "returningUser")
    }
    
    private func canUseLocalAuth(_ policy: LAPolicy) -> Bool {
        localAuth.canEvaluatePolicy(policy, error: nil)
    }
    
    private func showEnrolmentGuidance() {
        switch localAuth.biometryType {
        case .touchID:
            let touchIDEnrollmentScreen = viewControllerFactory
                .createTouchIDEnrollmentScreen(analyticsService: analyticsService) { [unowned self] in
                    storeAccessToken()
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
    
    private func storeAccessToken() {
        guard let tokenResponse = tokenHolder.tokenResponse else { return }
        do {
            try secureStore.saveItem(item: tokenResponse.accessToken, itemName: "accessToken")
            UserDefaults.standard.set(tokenResponse.expiryDate, forKey: "accessTokenExpiry")
        } catch {
            print("error")
        }
    }
    
    private func enrolLocalAuth(reason: String) async {
        do {
            if try await localAuth
                .evaluatePolicy(.deviceOwnerAuthentication, localizedReason: NSLocalizedString(reason, comment: "")) {
                storeAccessToken()
                finish()
            } else {
                return
            }
        } catch {
            return
        }
    }
}
