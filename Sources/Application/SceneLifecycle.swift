import GAnalytics
import Logging
import UIKit

@MainActor
protocol SceneLifecycle: AnyObject {
    var windowScene: UIWindowScene? { get set }
    var coordinator: MainCoordinator? { get set }
    var analyticsService: AnalyticsService { get }
    var unlockWindow: UIWindow? { get set }
}

extension SceneLifecycle {
    func displayUnlockScreen() {
        guard let windowScene else { return }
        unlockWindow = UIWindow(windowScene: windowScene)
        let unlockScreenViewModel = UnlockScreenViewModel(analyticsService: analyticsService) { [unowned self] in
            promptToUnlock()
        }
        unlockWindow?.rootViewController = UnlockScreenViewController(viewModel: unlockScreenViewModel)
        unlockWindow?.windowLevel = .alert
        unlockWindow?.makeKeyAndVisible()
    }
    
    func promptToUnlock() {
        coordinator?.evaluateRevisit {
            unlockWindow?.isHidden = true
            unlockWindow = nil
        }
    }
}
