import GDSAnalytics
import GDSCommon
import Logging

struct SignOutErrorViewModel: GDSErrorViewModelV3,
                              BaseViewModel {
    let image: ErrorScreenImage = .error
    let title: GDSLocalisedString = "app_signOutErrorTitle"
    let bodyContent: [ScreenBodyItem]
    let buttonViewModels: [ButtonViewModel]
    let analyticsService: OneLoginAnalyticsService
    let error: Error
    let withWallet: Bool
    
    let rightBarButtonTitle: GDSLocalisedString? = "app_cancelButton"
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         error: Error,
         withWallet: Bool,
         buttonAction: @escaping () -> Void) {
        self.bodyContent = [BodyTextViewModel(text: withWallet ? "app_signOutErrorBody" : "app_signOutErrorBodyNoWallet")]
        self.analyticsService = analyticsService
        self.error = error
        self.withWallet = withWallet
        self.buttonViewModels = [AnalyticsButtonViewModel(titleKey: withWallet ? "app_signOutErrorButton" : "app_exitButton",
                                                          analyticsService: analyticsService) {
            if withWallet {
                buttonAction()
            } else {
                fatalError("We were unable to sign the user out, they've been given guidance to delete the app")
            }
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
