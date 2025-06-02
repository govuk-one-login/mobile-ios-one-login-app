import GDSAnalytics
import GDSCommon
import Logging

struct SignOutErrorViewModel: GDSErrorViewModelV3,
                              BaseViewModel {
    let analyticsService: OneLoginAnalyticsService
    let error: Error
    let title: GDSLocalisedString = "app_signOutErrorTitle"
    let bodyContent: [ScreenBodyItem] = [BodyTextViewModel(text: "app_signOutErrorBody")]
    let buttonViewModels: [ButtonViewModel]
    let image: ErrorScreenImage = .error
    
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         error: Error) {
        self.analyticsService = analyticsService
        self.error = error
        self.buttonViewModels = [
            AnalyticsButtonViewModel(titleKey: "app_exitButton",
                                     analyticsService: analyticsService) {
                                         fatalError("We were unable to sign the user out, they've been given guidance to delete the app")
                                     }
        ]
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
