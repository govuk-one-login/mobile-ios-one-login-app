import GDSAnalytics
import GDSCommon
import Logging

struct SignOutWarningViewModel: GDSErrorViewModel, BaseViewModel {
    let image: String = "exclamationmark.circle"
    let title: GDSLocalisedString = "app_signOutWarningTitle"
    let body: GDSLocalisedString = "app_signOutWarningBody"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService,
         action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_signInButton",
                                                               analyticsService: analyticsService) {
            action()
        }
    }
    
    func didAppear() { /* BaseViewModel compliance */ }
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
