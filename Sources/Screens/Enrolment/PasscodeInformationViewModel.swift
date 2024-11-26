import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct PasscodeInformationViewModel: GDSInformationViewModelV2,
                                     GDSInformationViewModelPrimaryButton,
                                     BaseViewModel {
    let image: String = "lock"
    let imageWeight: UIFont.Weight? = nil
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 44
    let title: GDSLocalisedString = "app_noPasscodeSetupTitle"
    let body: GDSLocalisedString? = "app_noPasscodeSetupBody"
    let primaryButtonViewModel: ButtonViewModel
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService,
         action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        let event = LinkEvent(textKey: "app_continueButton",
                              linkDomain: AppEnvironment.oneLoginBaseURLString,
                              external: .false)
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_continueButton",
                                                               analyticsService: analyticsService,
                                                               analyticsEvent: event) {
            action()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(id: InformationAnalyticsScreenID.passcodeInfoScreen.rawValue,
                                screen: InformationAnalyticsScreen.passcode,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* Conforming to BaseViewModel */ }
}
