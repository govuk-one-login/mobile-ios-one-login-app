import GDSAnalytics
import GDSCommon
import Logging

class HomeTabViewModel: TabbedViewModel {
    let navigationTitle: GDSLocalisedString = "app_homeTitle"
    let sectionModels: [TabbedViewSectionModel]
    var analyticsService: AnalyticsService

    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    var isLoggedIn = false
    
    init(analyticsService: AnalyticsService,
         sectionModels: [TabbedViewSectionModel] = [TabbedViewSectionModel]()) {
        self.analyticsService = analyticsService
        self.sectionModels = sectionModels
    }
    
    func didAppear() {
        if isLoggedIn {
            analyticsService.setAdditionalParameters(appTaxonomy: .home)
            let screen = ScreenView(id: HomeAnalyticsScreenID.homeScreen.rawValue,
                                    screen: HomeAnalyticsScreen.homeScreen,
                                    titleKey: "app_homeTitle")
            analyticsService.trackScreen(screen)
        }
    }
    
    func didDismiss() { /* protocol conformance */ }
}
