import Logging
@testable import OneLogin
import UIKit

final class MockWindowManager: WindowManagement {
    let windowScene: UIWindowScene
    let appWindow: UIWindow
    var unlockWindow: UIWindow?
    var displayUnlockWindowCalled = false
    var hideUnlockWindowCalled = false
    
    init(appWindow: UIWindow) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        self.windowScene = windowScene!
        self.appWindow = appWindow
    }
    
    func displayUnlockWindow(analyticsService: AnalyticsService) {
        displayUnlockWindowCalled = true
    }
    
    func hideUnlockWindow() {
        hideUnlockWindowCalled = true
    }
}
