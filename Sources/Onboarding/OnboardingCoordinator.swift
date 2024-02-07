import Coordination
import LocalAuthentication
import Logging
import UIKit

final class OnboardingCoordinator: NSObject,
                                   ChildCoordinator,
                                   NavigationCoordinator {
    let root: UINavigationController
    var parentCoordinator: ParentCoordinator?
    let localAuth: LAContexting
    let analyticsService: AnalyticsService
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    
    init(root: UINavigationController,
         analyticsService: AnalyticsService,
         localAuth: LAContexting = LAContext()) {
        self.root = root
        self.analyticsService = analyticsService
        self.localAuth = localAuth
    }
    
    func start() {
        root.isNavigationBarHidden = true
        if localAuth.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            switch localAuth.biometryType {
            case .touchID:
                let touchIDEnrollmentScreen = viewControllerFactory
                    .createTouchIDEnrollmentScreen(analyticsService: analyticsService) { [unowned self] in
                        finish()
                    } secondaryButtonAction: { [unowned self] in
                        finish()
                    }
                root.pushViewController(touchIDEnrollmentScreen, animated: true)
            case .faceID:
                let faceIDEnrollmentScreen = viewControllerFactory
                    .createFaceIDEnrollmentScreen(analyticsService: analyticsService) { [unowned self] in
                        finish()
                    } secondaryButtonAction: { [unowned self] in
                        finish()
                    }
                root.pushViewController(faceIDEnrollmentScreen, animated: true)
            case .none, .opticID:
                return
            @unknown default:
                return
            }
        } else {
            let passcodeInformationScreen = viewControllerFactory
                .createPasscodeInformationScreen(analyticsService: analyticsService) { [unowned self] in
                    finish()
                }
            root.pushViewController(passcodeInformationScreen, animated: true)
        }
    }
}
