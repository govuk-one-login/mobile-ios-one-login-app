import GDSAnalytics
import GDSCommon
import Logging

struct GenericErrorViewModel: GDSErrorViewModel, BaseViewModel {
    let image: String = "exclamationmark.circle"
    let title: GDSLocalisedString = "app_somethingWentWrongErrorTitle"
    let body: GDSLocalisedString = "app_somethingWentWrongErrorBody"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService, action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        let event = LinkEvent(textKey: "app_closeButton",
                              linkDomain: AppEnvironment.oneLoginBaseURL,
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
                                     titleKey: title.stringKey, reason: "Generic error")
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() {
        // Here for BaseViewModel compliance
    }
}
