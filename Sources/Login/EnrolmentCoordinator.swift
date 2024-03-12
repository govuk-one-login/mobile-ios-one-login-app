import Coordination
import LocalAuthentication
import Logging
import UIKit

final class EnrolmentCoordinator: NSObject,
                                  ChildCoordinator,
                                  NavigationCoordinator {
    let root: UINavigationController
    var parentCoordinator: ParentCoordinator?
    let analyticsService: AnalyticsService
    let userStore: UserStorable
    let localAuth: LAContexting
    let tokenHolder: TokenHolder
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    
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
            storeAccessTokenInfo()
            finish()
        }
        userStore.defaultsStore.set(true, forKey: .returningUser)
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
    
    private func storeAccessTokenInfo() {
        guard let tokenResponse = tokenHolder.tokenResponse else { return }
        do {
            try userStore.secureStoreService.saveItem(item: tokenResponse.accessToken, itemName: .accessToken)
            if AppEnvironment.extendExpClaimEnabled {
                userStore.defaultsStore.set(tokenResponse.expiryDate + 27 * 60, forKey: .accessTokenExpiry)
            } else {
                userStore.defaultsStore.set(tokenResponse.expiryDate, forKey: .accessTokenExpiry)
            }
        } catch {
            print("error")
        }
    }
    
    func enrolLocalAuth(reason: String) async {
        do {
            if try await localAuth
                .evaluatePolicy(.deviceOwnerAuthentication, localizedReason: NSLocalizedString(reason, comment: "")) {
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
