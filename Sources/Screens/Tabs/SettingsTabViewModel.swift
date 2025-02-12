import GDSAnalytics
import GDSCommon
import Logging

@MainActor
struct SettingsTabViewModel: TabbedViewModel {
    let navigationTitle: GDSLocalisedString = "app_settingsTitle"
    let sectionModels: [TabbedViewSectionModel]
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    var isLoggedIn = false
    
    init(analyticsService: AnalyticsService,
         sectionModels: [TabbedViewSectionModel] = [TabbedViewSectionModel]()) {
        var tempAnalyticsService = analyticsService
        tempAnalyticsService.setAdditionalParameters(appTaxonomy: .settings)
        self.analyticsService = tempAnalyticsService
        self.sectionModels = sectionModels
    }
    
    func didAppear() {
        if isLoggedIn {
            let screen = ScreenView(id: SettingsAnalyticsScreenID.settingsScreen.rawValue,
                                    screen: SettingsAnalyticsScreen.settingsScreen,
                                    titleKey: navigationTitle.stringKey)
            analyticsService.trackScreen(screen)
        }
    }
    
    func didDismiss() { /* protocol conformance */ }
}
