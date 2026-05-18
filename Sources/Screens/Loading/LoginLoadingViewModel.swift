import DesignSystem
import GDSAnalytics
import Logging

struct LoadingViewModel: GDSScreenViewModel, BaseViewModel {
    let screenStyle: GDSScreenStyle = .centred
    let body: [any ContentViewModel] = [
        GDSProgressIndicatorViewModel()
    ]
    let movableFooter: [any ContentViewModel] = []
    let footer: [any ContentViewModel] = []
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    var didAppear: DesignSystem.Action? {
        .action {
            let loadingLabelKey: GDSLocalisedString = "app_loadingBody"
            let screen = ScreenView(id: IntroAnalyticsScreenID.loginLoading.rawValue,
                                    screen: IntroAnalyticsScreen.loginLoading,
                                    titleKey: loadingLabelKey.stringKey)
            analyticsService.trackScreen(screen)
        }
    }
    var didDismiss: DesignSystem.Action?
    
    let analyticsService: OneLoginAnalyticsService
    
    init(analyticsService: OneLoginAnalyticsService) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.system,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
    }
}
