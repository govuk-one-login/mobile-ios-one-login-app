import GDSAnalytics
import GDSCommon
import Logging

struct UnableToLoginErrorViewModel: GDSErrorViewModelV2,
                                    GDSErrorViewModelWithImage,
                                    BaseViewModel {
    let image: String = "exclamationmark.circle"
    let title: GDSLocalisedString = "app_signInErrorTitle"
    let body: GDSLocalisedString = "app_signInErrorBody"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: OneLoginAnalyticsService
    let errorDescription: String
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         errorDescription: String,
         action: @escaping () -> Void) {
        var tempAnalyticsService = analyticsService
        tempAnalyticsService.setAdditionalParameters(appTaxonomy: .loginError)
        self.analyticsService = tempAnalyticsService
        self.errorDescription = errorDescription
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
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
