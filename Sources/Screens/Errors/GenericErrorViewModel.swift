import GDSAnalytics
import GDSCommon
import Logging

struct GenericErrorViewModel: GDSErrorViewModelV3,
                              BaseViewModel {
    let analyticsService: OneLoginAnalyticsService
    let errorDescription: String
    let title: GDSLocalisedString = "app_genericErrorPage"
    let bodyContent: [ScreenBodyItem] = [BodyTextViewModel(text: "app_genericErrorPageBody")]
    let buttonViewModels: [ButtonViewModel]
    let image: ErrorScreenImage = .error

    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true

    init(analyticsService: OneLoginAnalyticsService,
         errorDescription: String,
         action: @escaping () -> Void) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.system,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        self.errorDescription = errorDescription
        let event = LinkEvent(textKey: "app_tryAgainButton",
                              linkDomain: AppEnvironment.mobileBaseURLString,
                              external: .false)
        self.buttonViewModels = [
            AnalyticsButtonViewModel(titleKey: "app_tryAgainButton",
                                     analyticsService: analyticsService,
                                     analyticsEvent: event) {
                                         action()
                                     }
        ]
    }
    
    func didAppear() {
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.generic.rawValue,
                                     screen: ErrorAnalyticsScreen.generic,
                                     titleKey: title.stringKey,
                                     reason: errorDescription)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
