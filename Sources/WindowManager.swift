import Logging
import UIKit

@MainActor
final class WindowManager: WindowManagement {
    let windowScene: UIWindowScene
    let appWindow: UIWindow
    var unlockWindow: UIWindow?

    init(windowScene: UIWindowScene) {
        self.windowScene = windowScene
        self.appWindow = UIWindow(windowScene: windowScene)
    }

    func displayUnlockWindow(analyticsService: AnalyticsService) {
        unlockWindow = UIWindow(windowScene: windowScene)
        let unlockScreenViewModel = UnlockScreenViewModel(analyticsService: analyticsService) { }
        unlockWindow?.rootViewController = UnlockScreenViewController(viewModel: unlockScreenViewModel)
        unlockWindow?.windowLevel = .alert
        unlockWindow?.makeKeyAndVisible()
    }

    func hideUnlockWindow() {
        unlockWindow?.isHidden = true
        unlockWindow = nil
    }
}
