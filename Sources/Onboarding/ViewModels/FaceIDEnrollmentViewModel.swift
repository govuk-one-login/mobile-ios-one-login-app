import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct FaceIDEnrollmentViewModel: GDSInformationViewModel, BaseViewModel {
    let image: String = "faceid"
    let imageWeight: UIFont.Weight? = .thin
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 64
    // TODO: DCMAW-7083: String keys for localisation needed
    let title: GDSLocalisedString = "Use Face ID to sign in"
    let body: GDSLocalisedString? = """
    Add a layer of security and sign in with your face instead of your email address and password. Your Face ID is not shared with GOV.UK One Login.\n
    If you do not want to use Face ID, you can sign in with your phone passcode instead.
    """
    let footnote: GDSLocalisedString? = "If you use Face ID, anyone with a Face ID saved to your phone will be able to sign in to this app."
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel?
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    let analyticsService: AnalyticsService

    init(analyticsService: AnalyticsService,
         primaryButtonAction: @escaping () -> Void,
         secondaryButtonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "Use Face ID",
                                                               analyticsService: analyticsService) {
            primaryButtonAction()
        }
        self.secondaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "Use passcode",
                                                                 icon: nil,
                                                                 analyticsService: analyticsService) {
              secondaryButtonAction()
          }
    }


    func didAppear() {
        let screen = ScreenView(screen: BiometricEnrollmentAnalyticsScreen.faceIDEnrollment, titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }

    func didDismiss() {
        // Conforming to BaseViewModel
    }
}
