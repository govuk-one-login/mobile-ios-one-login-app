import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct FaceIDEnrolmentViewModel: GDSInformationViewModelV2,
                                 GDSInformationViewModelWithFootnote,
                                 GDSInformationViewModelPrimaryButton,
                                 GDSInformationViewModelWithSecondaryButton,
                                 BaseViewModel {
    let image: String = "faceid"
    let imageWeight: UIFont.Weight? = .thin
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 64
    let title: GDSLocalisedString = "app_enableFaceIDTitle"
    let body: GDSLocalisedString? = "app_enableFaceIDBody"
    let footnote: GDSLocalisedString = "app_enableFaceIDFootnote"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService,
         primaryButtonAction: @escaping () -> Void,
         secondaryButtonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_enableFaceIDButton",
                                                               analyticsService: analyticsService) {
            primaryButtonAction()
        }
        self.secondaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_maybeLaterButton",
                                                                 analyticsService: analyticsService) {
            secondaryButtonAction()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(id: BiometricEnrolmentAnalyticsScreenID.faceIDEnrollment.rawValue,
                                screen: BiometricEnrolmentAnalyticsScreen.faceIDEnrollment,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* Conforming to BaseViewModel */ }
}
