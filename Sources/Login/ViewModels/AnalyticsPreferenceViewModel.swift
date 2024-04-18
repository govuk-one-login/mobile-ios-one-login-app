import GDSCommon
import Logging
import UIKit

typealias ModalInfoWithButtons = ModalInfoViewModel &
                                 ModalInfoExtraViewModel &
                                 PageWithPrimaryButtonViewModel &
                                 PageWithSecondaryButtonViewModel &
                                 PageWithTextButtonViewModel &
                                 BaseViewModel

struct AnalyticsPreferenceViewModel: ModalInfoWithButtons {
    let title: GDSLocalisedString = "app_acceptAnalyticsPreferences_title"
    let body: GDSLocalisedString = "acceptAnalyticsPreferences_body"
    let bodyTextColor: UIColor = .label
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel
    let textButtonViewModel: ButtonViewModel
    let preventModalDismiss: Bool = true

    var rightBarButtonTitle: GDSLocalisedString?
    var backButtonIsHidden: Bool = true
    
    init(primaryButtonAction: @escaping () -> Void,
         secondaryButtonAction: @escaping () -> Void,
         privacyPolicyButtonAction: @escaping () -> Void) {
        self.primaryButtonViewModel = StandardButtonViewModel(titleKey: "app_agreeButton") {
            primaryButtonAction()
        }
        self.secondaryButtonViewModel = StandardButtonViewModel(titleKey: "app_disagreeButton") {
            secondaryButtonAction()
        }
        self.textButtonViewModel = StandardButtonViewModel(titleKey: "app_privacyNoticeLink") {
            privacyPolicyButtonAction()
        }
    }
    
    func didAppear() {
        // Conforming to BaseViewModel
    }
    
    func didDismiss() {
        // Conforming to BaseViewModel
    }
}
