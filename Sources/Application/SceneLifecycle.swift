import GAnalytics
import GDSAnalytics
import Logging
import UIKit

@MainActor
protocol SceneLifecycle: AnyObject {
    var analyticsService: OneLoginAnalyticsService { get }
}

extension SceneLifecycle {
    func trackSplashScreen() {
        let splashAnalytics = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.system,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        let screen = ScreenView(
            id: IntroAnalyticsScreenID.splash.rawValue,
            screen: IntroAnalyticsScreen.splash,
            titleKey: "one login splash screen"
        )
        splashAnalytics.trackScreen(screen)
    }
}
