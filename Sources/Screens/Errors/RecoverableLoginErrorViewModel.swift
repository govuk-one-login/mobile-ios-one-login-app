import GDSAnalytics
import GDSCommon
import Logging

struct RecoverableLoginErrorViewModel: GDSErrorViewModelV3,
                                       BaseViewModel {
    let analyticsService: OneLoginAnalyticsService
    let errorDescription: String
    let title: GDSLocalisedString = "app_signInErrorTitle"
    let bodyContent: [ScreenBodyItem] = [BodyTextViewModel(text: "app_signInErrorRecoverableBody")]
    let buttonViewModels: [ButtonViewModel]
    let image: ErrorScreenImage = .error
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         errorDescription: String,
         action: @escaping () -> Void) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.login,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        self.errorDescription = errorDescription
        self.buttonViewModels = [
            AnalyticsButtonViewModel(titleKey: "app_tryAgainButton",
                                     analyticsService: analyticsService) {
                                         action()
                                     }
        ]
    }
    
    func didAppear() {
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.recoverableLoginError.rawValue,
                                     screen: ErrorAnalyticsScreen.recoverablLoginError,
                                     titleKey: title.stringKey,
                                     reason: errorDescription)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
