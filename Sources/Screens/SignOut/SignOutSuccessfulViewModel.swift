import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct SignOutSuccessfulViewModel: GDSCentreAlignedViewModel,
                                   GDSCentreAlignedViewModelWithPrimaryButton {
    let title: GDSLocalisedString = "app_signedOutTitle"
    var body: GDSLocalisedString? = "app_signedOutBodyNoWallet"
    let primaryButtonViewModel: ButtonViewModel
    
    init(buttonAction: @escaping () -> Void) {
        self.primaryButtonViewModel = StandardButtonViewModel(
            titleKey: GDSLocalisedString(stringLiteral: "app_continueButton").value
        ) {
            buttonAction()
        }
    }
}
