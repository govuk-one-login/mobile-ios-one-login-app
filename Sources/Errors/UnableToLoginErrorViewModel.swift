import GDSAnalytics
import GDSCommon
import Logging

struct UnableToLoginErrorViewModel: GDSErrorViewModel, BaseViewModel {
    let image: String = "exclamationmark.circle"
    let title: GDSLocalisedString = "app_signInErrorTitle"
    let body: GDSLocalisedString = "app_signInErrorBody"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService
    let errorDescription: String
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(errorDescription: String, analyticsService: AnalyticsService, action: @escaping () -> Void) {
        self.errorDescription = errorDescription
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_closeButton",
                                                               analyticsService: analyticsService) {
            action()
        }
    }
    
    func didAppear() {
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.unableToLogin.rawValue,
                                     screen: ErrorAnalyticsScreen.unableToLogin,
                                     titleKey: title.stringKey,
                                     reason: errorDescription)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() {
        // Here for BaseViewModel compliance
    }
}
