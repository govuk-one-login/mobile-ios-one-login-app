import GDSCommon
import Logging
import UIKit

typealias ModalInfoWithButtons = ModalInfoViewModel &
                                 ModalInfoExtraViewModel &
                                 PageWithPrimaryButtonViewModel &
                                 PageWithSecondaryButtonViewModel &
                                 PageWithTextButtonViewModel

struct AnalyticsPreferenceViewModel: ModalInfoWithButtons {
    let title: GDSLocalisedString = "app_acceptAnalyticsPreferences_title"
    let body: GDSLocalisedString = "acceptAnalyticsPreferences_body"
    let bodyTextColor: UIColor = .label
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel
    let textButtonViewModel: ButtonViewModel
    let preventModalDismiss: Bool = true
    
    init(primaryButtonAction: @escaping () -> Void,
         secondaryButtonAction: @escaping () -> Void,
         textButtonAction: @escaping () -> Void) {
        self.primaryButtonViewModel = StandardButtonViewModel(titleKey: "app_shareAnalyticsButton") {
            primaryButtonAction()
        }
        self.secondaryButtonViewModel = StandardButtonViewModel(titleKey: "app_doNotShareAnalytics") {
            secondaryButtonAction()
        }
        self.textButtonViewModel = StandardButtonViewModel(titleKey: "app_privacyNoticeLink",
                                                           titleStringVariableKeys: "app_nameString",
                                                           accessibilityHint: "app_externalBrowser") {
            textButtonAction()
        }
    }
}
