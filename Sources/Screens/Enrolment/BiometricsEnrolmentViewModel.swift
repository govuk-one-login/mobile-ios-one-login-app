import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct BiometricsEnrolmentViewModel: GDSCentreAlignedViewModel,
                                 GDSCentreAlignedViewModelWithImage,
                                 GDSCentreAlignedViewModelWithPrimaryButton,
                                 GDSCentreAlignedViewModelWithSecondaryButton,
                                 BaseViewModel {
    let image: String = "faceid"
    let imageWeight: UIFont.Weight? = .thin
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 64
    let title: GDSLocalisedString = "app_enableFaceIDTitle"
    let body: GDSLocalisedString? = "app_enableFaceIDBody"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel
    let analyticsService: OneLoginAnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         primaryButtonAction: @escaping () -> Void,
         secondaryButtonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_enableFaceIDButton",
                                                               analyticsService: analyticsService) {
            primaryButtonAction()
        }
        self.secondaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_skipButton",
                                                                 analyticsService: analyticsService) {
            secondaryButtonAction()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(id: BiometricEnrolmentAnalyticsScreenID.faceIDEnrolment.rawValue,
                                screen: BiometricEnrolmentAnalyticsScreen.faceIDEnrolment,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* Conforming to BaseViewModel */ }
}
