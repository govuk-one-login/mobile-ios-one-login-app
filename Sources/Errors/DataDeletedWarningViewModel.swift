import GDSAnalytics
import GDSCommon
import Logging

struct DataDeletedWarningViewModel: GDSErrorViewModelV2, GDSErrorViewModelWithImage, BaseViewModel {
    let image: String = "exclamationmark.circle"
    let title: GDSLocalisedString = "app_somethingWentWrongErrorTitle"
    let body: GDSLocalisedString = "app_dataDeletionWarningBody"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService,
         action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_extendedSignInButton",
                                                               analyticsService: analyticsService) {
            action()
        }
    }
    
    func didAppear() { /* BaseViewModel compliance */ }
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
