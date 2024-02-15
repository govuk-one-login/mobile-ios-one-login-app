import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct PasscodeInformationViewModel: GDSInformationViewModel, BaseViewModel {
    let image: String = "lock"
    let imageWeight: UIFont.Weight? = nil
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 44
    let title: GDSLocalisedString = "app_noPasscodeSetupTitle"
    let body: GDSLocalisedString? = "app_noPasscodeSetupBody"
    let footnote: GDSLocalisedString? = nil
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService, action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_continueButton",
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
