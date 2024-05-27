import GDSAnalytics
import GDSCommon
import Logging

struct LoginLoadingViewModel: GDSLoadingViewModel, BaseViewModel {
    let loadingLabelKey: GDSLocalisedString = "app_loadingBody"
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    func didAppear() {
        let screen = ScreenView(id: IntroAnalyticsScreenID.loginLoadingScreen.rawValue,
                                screen: IntroAnalyticsScreen.loginLoadingScreen,
                                titleKey: loadingLabelKey.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* Conforming to BaseViewModel */ }
}
