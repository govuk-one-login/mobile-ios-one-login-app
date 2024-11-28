import GDSAnalytics
import GDSCommon
import Logging

struct GenericErrorViewModel: GDSErrorViewModelV2,
                              GDSErrorViewModelWithImage,
                              BaseViewModel {
    let image: String = "exclamationmark.circle"
    let title: GDSLocalisedString = "app_somethingWentWrongErrorTitle"
    let body: GDSLocalisedString = "app_somethingWentWrongErrorBody"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService
    let errorDescription: String

    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true

    init(analyticsService: AnalyticsService,
         errorDescription: String,
         action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.errorDescription = errorDescription
        let event = LinkEvent(textKey: "app_closeButton",
                              linkDomain: AppEnvironment.mobileBaseURLString,
                              external: .false)
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_closeButton",
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
