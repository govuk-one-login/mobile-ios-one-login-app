import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct FaceIDEnrollmentViewModel: GDSInformationViewModel, BaseViewModel {
    let image: String = "faceid"
    let imageWeight: UIFont.Weight? = .thin
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 64
    let title: GDSLocalisedString = "app_enableFaceIDTitle"
    let body: GDSLocalisedString? = "app_enableFaceIDBody"
    let footnote: GDSLocalisedString? = "app_enableFaceIDFootnote"
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel?
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    let analyticsService: AnalyticsService
    
    init(analyticsService: AnalyticsService,
         primaryButtonAction: @escaping () -> Void,
         secondaryButtonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_enableFaceIDButton",
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
        let screen = ScreenView(screen: BiometricEnrollmentAnalyticsScreen.faceIDEnrollment,
                                titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() {
        // Conforming to BaseViewModel
    }
}
