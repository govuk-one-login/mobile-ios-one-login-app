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
        let screen = ScreenView(id: IntroAnalyticsScreenID.splash.rawValue,
                                screen: IntroAnalyticsScreen.splash,
                                titleKey: "one login splash screen")
        analyticsService.trackScreen(screen)
    }
}
