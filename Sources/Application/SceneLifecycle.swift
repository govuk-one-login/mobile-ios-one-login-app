import GAnalytics
import GDSAnalytics
import Logging
import UIKit

@MainActor
protocol SceneLifecycle: AnyObject {
    var analyticsService: AnalyticsService { get }
    var windowManager: WindowManagement? { get set }
}

extension SceneLifecycle {
    func displayUnlockScreen() {
        windowManager?.displayUnlockWindow(analyticsService: analyticsService) {
            
        }
    }
    
    func trackSplashScreen(_ analyticsService: AnalyticsService) {
        let screen = ScreenView(id: IntroAnalyticsScreenID.splashScreen.rawValue,
                                screen: IntroAnalyticsScreen.splashScreen,
                                titleKey: "one login splash screen")
        analyticsService.trackScreen(screen)
    }
}
