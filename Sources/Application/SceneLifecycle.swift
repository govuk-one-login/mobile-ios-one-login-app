import GAnalytics
import GDSAnalytics
import Logging
import UIKit

@MainActor
protocol SceneLifecycle: AnyObject {
    var analyticsService: AnalyticsService { get }
}

extension SceneLifecycle {
    func trackSplashScreen() {
        let screen = ScreenView(id: IntroAnalyticsScreenID.splashScreen.rawValue,
                                screen: IntroAnalyticsScreen.splashScreen,
                                titleKey: "one login splash screen")
        analyticsService.trackScreen(screen)
    }
}
