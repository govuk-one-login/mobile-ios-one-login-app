import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct TouchIDEnrollmentViewModel: GDSInformationViewModel, BaseViewModel {
    let image: String = "touchid"
    let imageWeight: UIFont.Weight? = .thin
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 64
    let title: GDSLocalisedString = "app_enableTouchIDTitle"
    let body: GDSLocalisedString? = "app_enableTouchIDBody"
    let footnote: GDSLocalisedString? = "app_enableTouchIDFootnote"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel?
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    let analyticsService: AnalyticsService
    
    init(analyticsService: AnalyticsService,
         primaryButtonAction: @escaping () -> Void,
         secondaryButtonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_enableTouchIDEnableButton",
                                                               analyticsService: analyticsService) {
            primaryButtonAction()
        }
        self.secondaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_usePasscodeButton",
                                                                 icon: nil,
                                                                 analyticsService: analyticsService) {
            secondaryButtonAction()
        }
    }
    
    
    func didAppear() {
        let screen = ScreenView(screen: BiometricEnrollmentAnalyticsScreen.touchIDEnrollment,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() {
        // Conforming to BaseViewModel
    }
}
