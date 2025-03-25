import GDSAnalytics
import GDSCommon
import Logging

struct GenericErrorViewModel: GDSErrorViewModelV2,
                              GDSErrorViewModelWithImage,
                              BaseViewModel {
    let image: String = "exclamationmark.circle"
    let title: GDSLocalisedString = "app_genericErrorPage"
    let body: GDSLocalisedString = "app_genericErrorPageBody"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: OneLoginAnalyticsService
    let errorDescription: String

    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true

    init(analyticsService: OneLoginAnalyticsService,
         errorDescription: String,
         action: @escaping () -> Void) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.system,
            OLTaxonomyKey.level3: OLTaxonomyValue.error
        ])
        self.errorDescription = errorDescription
        let event = LinkEvent(textKey: "app_tryAgainButton",
                              linkDomain: AppEnvironment.mobileBaseURLString,
                              external: .false)
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_tryAgainButton",
                                                               analyticsService: analyticsService,
                                                               analyticsEvent: event) {
            action()
        }
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
