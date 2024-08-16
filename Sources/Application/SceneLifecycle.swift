import GAnalytics
import GDSAnalytics
import Logging
import UIKit

@MainActor
protocol SceneLifecycle: AnyObject {
    var coordinator: MainCoordinator? { get set }
    var analyticsService: AnalyticsService { get }
}

extension SceneLifecycle {
    
    func trackSplashScreen(_ analyticsService: AnalyticsService) {
        let screen = ScreenView(id: IntroAnalyticsScreenID.splashScreen.rawValue,
                                screen: IntroAnalyticsScreen.splashScreen,
                                titleKey: "one login splash screen")
        analyticsService.trackScreen(screen)
    }
}
