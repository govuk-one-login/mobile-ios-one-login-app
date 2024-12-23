import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct TouchIDEnrolmentViewModel: GDSInformationViewModelV2,
                                  GDSInformationViewModelPrimaryButton,
                                  GDSInformationViewModelWithSecondaryButton,
                                  BaseViewModel {
    let image: String = "touchid"
    let imageWeight: UIFont.Weight? = .thin
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 64
    let title: GDSLocalisedString = "app_enableTouchIDTitle"
    let body: GDSLocalisedString? = "app_enableTouchIDBody"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService,
         primaryButtonAction: @escaping () -> Void,
         secondaryButtonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_enableTouchIDEnableButton",
                                                               analyticsService: analyticsService) {
            primaryButtonAction()
        }
        self.secondaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_skipButton",
                                                                 analyticsService: analyticsService) {
            secondaryButtonAction()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(id: BiometricEnrolmentAnalyticsScreenID.touchIDEnrolment.rawValue,
                                screen: BiometricEnrolmentAnalyticsScreen.touchIDEnrolment,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* Conforming to BaseViewModel */ }
}
