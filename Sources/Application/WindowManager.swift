import Logging
import UIKit

@MainActor
final class WindowManager: WindowManagement {
    let windowScene: UIWindowScene
    let appWindow: UIWindow
    var unlockWindow: UIWindow?
    weak var unlockScreen: UnlockScreenViewController?
    
    init(windowScene: UIWindowScene) {
        self.windowScene = windowScene
        self.appWindow = UIWindow(windowScene: windowScene)
    }
    
    func displayUnlockWindow(analyticsService: AnalyticsService, action: @escaping () -> Void) {
        unlockWindow = UIWindow(windowScene: windowScene)
        let unlockScreenViewModel = UnlockScreenViewModel(analyticsService: analyticsService) {
            action()
        }
        let unlockViewController = UnlockScreenViewController(viewModel: unlockScreenViewModel)
        unlockScreen = unlockViewController
        unlockWindow?.rootViewController = unlockViewController
        unlockWindow?.windowLevel = .alert
        unlockWindow?.makeKeyAndVisible()
    }
    
    func unlockScreenFinishLoading() {
        unlockScreen?.finishLoading()
    }
    
    func hideUnlockWindow() {
        unlockWindow?.isHidden = true
        unlockWindow = nil
    }
}
