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
    
    func displayUnlockWindow(analyticsService: AnalyticsService,
                             action: @escaping () -> Void) {
//        unlockWindow = UIWindow(windowScene: windowScene)
//        let unlockScreenViewModel = UnlockScreenViewModel(analyticsService: analyticsService) {
//            action()
//        }
//        unlockWindow?.rootViewController = UnlockScreenViewController(viewModel: unlockScreenViewModel)
//        unlockWindow?.windowLevel = .alert
//        unlockWindow?.makeKeyAndVisible()
    }
    
    func hideUnlockWindow() {
        unlockWindow?.isHidden = true
        unlockWindow = nil
    }
}
