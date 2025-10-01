import GDSAnalytics
import GDSCommon
import Logging

struct SignOutErrorViewModel: GDSErrorViewModelV3,
                              BaseViewModel {
    let image: ErrorScreenImage = .error
    let title: GDSLocalisedString = "app_signOutErrorTitle"
    let bodyContent: [ScreenBodyItem] = [BodyTextViewModel(text: "app_signOutErrorBody")]
    let buttonViewModels: [ButtonViewModel]
    let analyticsService: OneLoginAnalyticsService
    let error: Error
    
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         error: Error,
         buttonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.error = error
        self.buttonViewModels = [AnalyticsButtonViewModel(titleKey: "app_signOutErrorButton",
                                                          analyticsService: analyticsService) {
            buttonAction()
        }]
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
