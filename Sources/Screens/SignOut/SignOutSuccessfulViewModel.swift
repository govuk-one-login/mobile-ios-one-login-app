import GDSAnalytics
import GDSCommon
import Logging
import UIKit

// No analytics events for this screen as users analytics preference will have been deleted
struct SignOutSuccessfulViewModel: GDSCentreAlignedViewModel,
                                   GDSCentreAlignedViewModelWithPrimaryButton {
    let title: GDSLocalisedString = "app_signedOutTitle"
    var body: GDSLocalisedString? = "app_signedOutBody"
    let primaryButtonViewModel: ButtonViewModel
    
    init(buttonAction: @escaping () -> Void) {
        self.primaryButtonViewModel = StandardButtonViewModel(
            titleKey: "app_continueButton"
        ) {
            buttonAction()
        }
    }
}
