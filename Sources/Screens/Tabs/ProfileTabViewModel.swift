import GDSAnalytics
import GDSCommon
import Logging

struct ProfileTabViewModel: TabbedViewModel {
    let navigationTitle: GDSLocalisedString = "app_profileTitle"
    let sectionModels: [TabbedViewSectionModel]
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    var isLoggedIn = false
    
    init(analyticsService: AnalyticsService,
         sectionModels: [TabbedViewSectionModel] = [TabbedViewSectionModel]()) {
        var tempAnalyticsService = analyticsService
        tempAnalyticsService.setAdditionalParameters(appTaxonomy: .profile)
        self.analyticsService = tempAnalyticsService
        self.sectionModels = sectionModels
    }
    
    func didAppear() {
        if isLoggedIn {
            let screen = ScreenView(id: ProfileAnalyticsScreenID.profileScreen.rawValue,
                                    screen: ProfileAnalyticsScreen.profileScreen,
                                    titleKey: navigationTitle.stringKey)
            analyticsService.trackScreen(screen)
        }
    }
    
    func didDismiss() { /* protocol conformance */ }
}
