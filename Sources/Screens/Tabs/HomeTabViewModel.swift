import GDSAnalytics
import GDSCommon
import Logging

struct HomeTabViewModel: ContentViewModel {
    var navigationTitle: GDSLocalisedString = "app_homeTitle"
    let analyticsService: AnalyticsService
    let sectionModels: [ContentViewSectionModel]

    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    var isLoggedIn = false
    
    init(analyticsService: AnalyticsService,
         sectionModels: [ContentViewSectionModel] = [ContentViewSectionModel]()) {
        var tempAnalyticsService = analyticsService
        tempAnalyticsService.setAdditionalParameters(appTaxonomy: .home)
        self.analyticsService = tempAnalyticsService
        self.sectionModels = sectionModels
    }
    
    func didAppear() {
        if isLoggedIn {
            let screen = ScreenView(id: HomeAnalyticsScreenID.homeScreen.rawValue,
                                    screen: HomeAnalyticsScreen.homeScreen,
                                    titleKey: navigationTitle.stringKey)
            analyticsService.trackScreen(screen)
        }
    }
    
    func didDismiss() { /* protocol conformance */ }
}
