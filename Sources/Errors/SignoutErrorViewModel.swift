import GDSAnalytics
import GDSCommon
import Logging

struct SignoutErrorViewModel: GDSErrorViewModel, BaseViewModel {
    let image: String = "exclamationmark.circle"
    let title: GDSLocalisedString = "app_signOutErrorTitle"
    let body: GDSLocalisedString = "app_signOutErrorBody"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService
    let errorDescription: String
    
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    let backButtonIsHidden: Bool = true
    
    init(errorDescription: String, analyticsService: AnalyticsService, action: @escaping () -> Void) {
        self.errorDescription = errorDescription
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_exitButton",
                                                               analyticsService: analyticsService) {
            action()
        }
    }
    
    func didAppear() { /* BaseViewModel compliance */ }
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
