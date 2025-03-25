import GDSAnalytics
import GDSCommon
import Logging

struct NetworkConnectionErrorViewModel: GDSErrorViewModelV2,
                                        GDSErrorViewModelWithImage,
                                        BaseViewModel {
    let image: String = "exclamationmark.circle"
    let title: GDSLocalisedString = "app_networkErrorTitle"
    let body: GDSLocalisedString = "app_networkErrorBody"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: OneLoginAnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService, action: @escaping () -> Void) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.system,
            OLTaxonomyKey.level3: OLTaxonomyValue.error
        ])
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_tryAgainButton",
                                                               analyticsService: analyticsService) {
            action()
        }
    }
    
    func didAppear() {
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.networkConnection.rawValue,
                                     screen: ErrorAnalyticsScreen.networkConnection,
                                     titleKey: title.stringKey,
                                     reason: "network connection error")
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
