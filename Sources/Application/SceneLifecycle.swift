import GAnalytics
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
            windowManager?.hideUnlockWindow()
        }
    }
}
