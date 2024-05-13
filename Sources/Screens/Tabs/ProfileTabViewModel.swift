import GDSAnalytics
import GDSCommon
import Logging

class ProfileTabViewModel: TabbedViewModel {
    let rightBarButtonTitle: GDSLocalisedString?
    let backButtonIsHidden: Bool
    var analyticsService: AnalyticsService
    
    let navigationTitle: GDSLocalisedString = "app_profileTitle"
    let sectionModels: [TabbedViewSectionModel]
    
    var isLoggedIn = false
    
    init(rightBarButtonTitle: GDSLocalisedString? = nil,
         backButtonIsHidden: Bool = true,
         analyticsService: AnalyticsService,
         sectionModels: [TabbedViewSectionModel] = [TabbedViewSectionModel]()) {
        self.rightBarButtonTitle = rightBarButtonTitle
        self.backButtonIsHidden = backButtonIsHidden
        self.analyticsService = analyticsService
        self.sectionModels = sectionModels
    }
    
    func didAppear() {
        if isLoggedIn {
            analyticsService.setAdditionalParameters(appTaxonomy: .profile)
            let screen = ScreenView(id: TabAnalyticsScreenID.profile.rawValue,
                                    screen: TabAnalyticsScreen.profile,
                                    titleKey: navigationTitle.value)
            analyticsService.trackScreen(screen)
        }
    }
    
    func didDismiss() { /* protocol conformance */ }
}
