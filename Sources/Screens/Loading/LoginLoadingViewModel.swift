import GDSAnalytics
import GDSCommon
import Logging

struct LoginLoadingViewModel: GDSLoadingViewModel, BaseViewModel {
    let loadingLabelKey: GDSLocalisedString = "app_loadingBody"
    let analyticsService: OneLoginAnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.system,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
    }
    
    func didAppear() {
        let screen = ScreenView(id: IntroAnalyticsScreenID.loginLoading.rawValue,
                                screen: IntroAnalyticsScreen.loginLoading,
                                titleKey: loadingLabelKey.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* Conforming to BaseViewModel */ }
}
