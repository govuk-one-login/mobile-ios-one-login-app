import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct BiometricEnrollViewModel: GDSInformationViewModel, BaseViewModel {
    let image: String
    let imageWeight: UIFont.Weight? = .thin
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 64
    // TODO: DCMAW-7083: String keys for localisation needed
    let title: GDSLocalisedString
    let body: GDSLocalisedString? = """
    Add a layer of security and sign in with your face instead of your email address and password.
    Your Face ID is not shared with GOV.UK One Login.\n
    If you do not want to use Face ID, you can sign in with your phone passcode instead.
    """
    let footnote: GDSLocalisedString? = "If you use Face ID, anyone with a Face ID saved to your phone will be able to sign in to this app."

    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel?
    var rightBarButtonTitle: GDSLocalisedString?
    var backButtonIsHidden: Bool = true
    let analyticsService: AnalyticsService

    init(analyticsService: AnalyticsService,
         image: String,
         title: GDSLocalisedString,
         primaryButtonAction: @escaping () -> Void,
         secondaryButtonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.image = image
        self.title = title
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "Use Face ID",
                                                               analyticsService: analyticsService) {
            primaryButtonAction()
        }
        self.secondaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "Use passcode",
                                                                 analyticsService: analyticsService) {
              secondaryButtonAction()
          }

    }


    func didAppear() {
        let screen = ScreenView(screen: InformationAnalyticsScreen.passcode, titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }

    func didDismiss() {
        // Conforming to BaseViewModel
    }

}
