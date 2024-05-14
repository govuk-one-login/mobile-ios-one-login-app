import GDSAnalytics
import GDSCommon
import Logging

class ProfileTabViewModel: TabbedViewModel {
    let navigationTitle: GDSLocalisedString = "app_profileTitle"
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
            analyticsService.setAdditionalParameters(appTaxonomy: .profile)
            let screen = ScreenView(id: TabAnalyticsScreenID.profile.rawValue,
                                    screen: TabAnalyticsScreen.profile,
                                    titleKey: "app_profileTitle")
            analyticsService.trackScreen(screen)
        }
    }
    
    func didDismiss() { /* protocol conformance */ }
}
