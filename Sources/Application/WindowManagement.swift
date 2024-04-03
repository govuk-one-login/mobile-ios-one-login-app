import Logging
import UIKit

protocol WindowManagement {
    var windowScene: UIWindowScene { get }
    var appWindow: UIWindow { get }
    var unlockWindow: UIWindow? { get set }
    
    func displayUnlockWindow(analyticsService: AnalyticsService, action: @escaping () -> Void)
    func hideUnlockWindow()
}