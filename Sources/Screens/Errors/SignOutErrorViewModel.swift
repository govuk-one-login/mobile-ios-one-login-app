import GDSAnalytics
import GDSCommon
import Logging

struct SignOutErrorViewModel: GDSErrorViewModelV2,
                              GDSErrorViewModelWithImage,
                              BaseViewModel {
    let image: String = "exclamationmark.circle"
    let title: GDSLocalisedString = "app_signOutErrorTitle"
    let body: GDSLocalisedString = "app_signOutErrorBody"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService
    let error: Error
    
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService,
         error: Error) {
        self.analyticsService = analyticsService
        self.error = error
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_exitButton",
                                                               analyticsService: analyticsService) {
            fatalError("We were unable to sign the user out, they've been given guidance to delete the app")
        }
    }
    
    func didAppear() {
        analyticsService.logCrash(error)
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.signOut.rawValue,
                                     screen: ErrorAnalyticsScreen.signOut,
                                     titleKey: title.stringKey,
                                     reason: error.localizedDescription)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* BaseViewModel compliance */ }
}
