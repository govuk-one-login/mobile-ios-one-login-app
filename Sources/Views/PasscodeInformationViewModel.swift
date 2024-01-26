import GDSAnalytics
import GDSCommon
import Logging

struct PasscodeInformationViewModel: GDSInformationViewModel, BaseViewModel {
    let image: String = "lock"
    // TODO: DCMAW-7083: String keys for localisation needed
    let title: GDSLocalisedString = "You can sign in with a passcode"
    let body: GDSLocalisedString = "Add a layer of security and sign in with a passcode instead of your email address and password. \n\n You can set a passcode later by going to your phone settings."
    var footnote: GDSCommon.GDSLocalisedString? = nil
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService, action: @escaping () -> Void){
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "Continue",
                                                               analyticsService: analyticsService) {
            action()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(screen: InformationAnalyticsScreen.passcode, titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() {
        // Here for BaseViewModel compliance
    }
}
