import GAnalytics
import GDSAnalytics
import Logging
import UIKit

@MainActor
protocol SceneLifecycle: AnyObject {
    var coordinator: MainCoordinator? { get set }
    var analyticsService: AnalyticsService { get }
    var windowManager: WindowManagement? { get set }
}

extension SceneLifecycle {
    func displayUnlockScreen() {
        windowManager?.displayUnlockWindow(analyticsService: analyticsService) { [unowned self] in
            promptToUnlock()
        }
    }
    
    func promptToUnlock() {
        coordinator?.evaluateRevisit {
            let screen = ScreenView(id: BiometricEnrollmentAnalyticsScreenID.unlockScreen.rawValue,
                                    screen: BiometricEnrollmentAnalyticsScreen.unlockScreen,
                                    titleKey: "one login unlock screen")
            analyticsService.trackScreen(screen)
            windowManager?.hideUnlockWindow()
        }
    }
}
