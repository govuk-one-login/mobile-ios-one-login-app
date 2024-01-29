import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct PasscodeInformationViewModel: GDSInformationViewModel, BaseViewModel {
    let image: String = "lock"
    let imageWeight: UIFont.Weight = .semibold
    // TODO: DCMAW-7083: String keys for localisation needed
    let title: GDSLocalisedString = "You can sign in with a passcode"
    let body: GDSLocalisedString = "Setting a passcode on your phone adds security. You can then sign in this way instead of with your email address and password. \n\n You can set a passcode later by going to your phone settings."
    let footnote: GDSLocalisedString? = nil
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService, action: @escaping () -> Void) {
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
