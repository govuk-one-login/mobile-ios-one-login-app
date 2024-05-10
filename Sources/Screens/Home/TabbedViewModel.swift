import GDSAnalytics
import GDSCommon
import Logging
import UIKit

class TabbedViewModel: BaseViewModel {
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
    
    var numberOfSections: Int {
        sectionModels.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        sectionModels[section].tabModels.count
    }
    
    func didAppear() {
        if isLoggedIn, let navigationTitle {
            analyticsService.additionalParameters = analyticsService.additionalParameters.merging([
                "taxonomy_level2": navigationTitle.value.lowercased()
            ]) { $1 }
            var screen: ScreenView<TabAnalyticsScreen> {
                if navigationTitle.value == "Home" {
                    .init(id: TabAnalyticsScreenID.home.rawValue,
                          screen: TabAnalyticsScreen.home,
                          titleKey: navigationTitle.value)
                } else {
                    .init(id: TabAnalyticsScreenID.profile.rawValue,
                          screen: TabAnalyticsScreen.profile,
                          titleKey: navigationTitle.value)
                }
            }
            analyticsService.trackScreen(screen)
        }
    }
    
    func didDismiss() { /* protocol conformance */ }
}
