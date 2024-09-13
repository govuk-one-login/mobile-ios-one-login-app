import GDSCommon
import Logging

@MainActor
struct MockTabbedViewModel: TabbedViewModel {
    let navigationTitle: GDSLocalisedString
    let sectionModels: [TabbedViewSectionModel]
    let analyticsService: AnalyticsService

    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    var isLoggedIn: Bool = false
    
    let didAppearAction: () -> Void
    
    init(analyticsService: AnalyticsService,
         navigationTitle: GDSLocalisedString,
         sectionModels: [TabbedViewSectionModel],
         didAppearAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.navigationTitle = navigationTitle
        self.sectionModels = sectionModels
        self.didAppearAction = didAppearAction
    }
    
    func didAppear() {
        didAppearAction()
    }
    
    func didDismiss() { }
}
