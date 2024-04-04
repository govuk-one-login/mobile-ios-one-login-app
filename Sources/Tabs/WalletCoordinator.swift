import Coordination
import Logging
import UIKit
import Wallet

final class WalletCoordinator: NSObject,
                               AnyCoordinator,
                               ChildCoordinator,
                               NavigationCoordinator {
    let window: UIWindow
    var parentCoordinator: ParentCoordinator?
    let root = UINavigationController()
    let analyticsService: AnalyticsService
    
    init(window: UIWindow, analyticsService: AnalyticsService) {
        self.window = window
        self.analyticsService = analyticsService
    }
    
    func start() {
        let walletSDK = WalletSDK()
        walletSDK.start(in: window, with: root, analyticsService: analyticsService)
    }
}
