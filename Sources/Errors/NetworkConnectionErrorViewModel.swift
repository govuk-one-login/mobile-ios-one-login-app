import GDSAnalytics
import GDSCommon
import Logging

struct NetworkConnectionErrorViewModel: GDSErrorViewModel, BaseViewModel {
    let image: String = "exclamationmark.circle"
    let title: GDSLocalisedString = "app_networkErrorTitle"
    let body: GDSLocalisedString = "app_networkErrorBody"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService, action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_tryAgainButton",
                                                               analyticsService: analyticsService) {
            action()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(screen: ErrorAnalyticsScreen.networkConnection,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() {
        // Here for BaseViewModel compliance
    }
}
