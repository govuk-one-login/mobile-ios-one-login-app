import GDSAnalytics
import GDSCommon
import Logging

struct UnrecoverableLoginErrorViewModel: GDSErrorViewModelV3,
                                    BaseViewModel {
    let analyticsService: OneLoginAnalyticsService
    let errorDescription: String
    let title: GDSLocalisedString = "app_signInErrorTitle"
    let bodyContent: [ScreenBodyItem] = [BodyTextViewModel(text: "app_signInErrorUnrecoverableBody")]
    let buttonViewModels: [ButtonViewModel] = []
    let image: ErrorScreenImage = .error
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         errorDescription: String) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.login,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        self.errorDescription = errorDescription
    }
    
    func didAppear() {
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.unrecoverableLoginError.rawValue,
                                     screen: ErrorAnalyticsScreen.unrecoverablLoginError,
                                     titleKey: title.stringKey,
                                     reason: errorDescription)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
