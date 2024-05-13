import GDSAnalytics
import GDSCommon
import Logging

class HomeTabViewModel: TabbedViewModel, BaseViewModel {
    let rightBarButtonTitle: GDSLocalisedString?
    let backButtonIsHidden: Bool
    var analyticsService: AnalyticsService
    
    let navigationTitle: GDSLocalisedString?
    let sectionModels: [TabbedViewSectionModel]
    
    var isLoggedIn = false
    
    init(rightBarButtonTitle: GDSLocalisedString? = nil,
         backButtonIsHidden: Bool = true,
         analyticsService: AnalyticsService,
         title: GDSLocalisedString? = nil,
         sectionModels: [TabbedViewSectionModel] = [TabbedViewSectionModel]()) {
        self.rightBarButtonTitle = rightBarButtonTitle
        self.backButtonIsHidden = backButtonIsHidden
        self.analyticsService = analyticsService
        self.navigationTitle = title
        self.sectionModels = sectionModels
    }
    
    func didAppear() {
        if isLoggedIn, let navigationTitle {
            analyticsService.setAdditionalParameters(appTaxonomy: .home)
            let screen = ScreenView(id: TabAnalyticsScreenID.home.rawValue,
                                    screen: TabAnalyticsScreen.home,
                                    titleKey: navigationTitle.value)
            analyticsService.trackScreen(screen)
        }
    }
    
    func didDismiss() { /* protocol conformance */ }
}
