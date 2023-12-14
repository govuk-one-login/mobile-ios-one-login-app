import GDSAnalytics
import GDSCommon
import Logging

struct UnableToLoginErrorViewModel: GDSErrorViewModel, BaseViewModel {
    // TODO: String keys for localisation needed
    let image: String = "exclamationmark.circle"
    let title: GDSLocalisedString = "There was a problem signing you in"
    let body: GDSLocalisedString = "You can try signing in again.\n\nIf this does not work, you may need to try again later."
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService, action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "Close",
                                                               analyticsService: analyticsService) {
            action()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(screen: ErrorAnalyticsScreen.unableToLogin,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() {
        // Here for BaseViewModel compliance
    }
}
