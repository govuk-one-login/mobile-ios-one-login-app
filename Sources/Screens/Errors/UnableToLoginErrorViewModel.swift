import GDSAnalytics
import GDSCommon
import Logging

struct UnableToLoginErrorViewModel: GDSErrorViewModelV3,
                                    BaseViewModel {
    let analyticsService: OneLoginAnalyticsService
    let errorDescription: String
    let title: GDSLocalisedString = "app_signInErrorTitle"
    let bodyContent: [ScreenBodyItem] = [BodyTextViewModel(text: "app_signInErrorBody")]
    let buttonViewModels: [ButtonViewModel]
    let image: ErrorScreenImage = .error
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         errorDescription: String,
         action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.errorDescription = errorDescription
        self.buttonViewModels = [
            AnalyticsButtonViewModel(titleKey: "app_signInErrorButton",
                                     analyticsService: analyticsService) {
                                         action()
                                     }
        ]
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
