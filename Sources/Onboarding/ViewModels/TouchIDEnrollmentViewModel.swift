import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct TouchIDEnrollmentViewModel: GDSInformationViewModel, BaseViewModel {
    let image: String = "touchid"
    let imageWeight: UIFont.Weight? = .thin
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 64
    let title: GDSLocalisedString = "app_enableTouchIdTitle"
    let body: GDSLocalisedString? = "app_enableTouchIdBody"
    let footnote: GDSLocalisedString? = "app_enableTouchIdFootnote"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel?
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    let analyticsService: AnalyticsService

    init(analyticsService: AnalyticsService,
         primaryButtonAction: @escaping () -> Void,
         secondaryButtonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_enableTouchIdEnableButton",
                                                               analyticsService: analyticsService) {
            primaryButtonAction()
        }
        self.secondaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_enablePasscodeButton",
                                                                 icon: nil,
                                                                 analyticsService: analyticsService) {
              secondaryButtonAction()
          }
    }


    func didAppear() {
        let screen = ScreenView(screen: BiometricEnrollmentAnalyticsScreen.touchIDEnrollment, titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }

    func didDismiss() {
        // Conforming to BaseViewModel
    }
}
