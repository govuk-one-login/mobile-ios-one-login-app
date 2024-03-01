import GDSCommon
import Logging
import UIKit

struct AnalyticsPreferenceViewModel: ModalInfoButtonsViewModel, BaseViewModel {
    let title: GDSLocalisedString = "app_acceptAnalyticsPreferences_title"
    let body: GDSLocalisedString = "acceptAnalyticsPreferences_body"
    let bodyTextColour: UIColor? = .label
    let primaryButtonViewModel: ButtonViewModel?
    let secondaryButtonViewModel: ButtonViewModel?
    let preventModalDismiss: Bool? = true
    
    var rightBarButtonTitle: GDSLocalisedString?
    var backButtonIsHidden: Bool = true
    
    init(primaryButtonAction: @escaping () -> Void,
         secondaryButtonAction: @escaping () -> Void) {
        self.primaryButtonViewModel = StandardButtonViewModel(titleKey: "app_agreeButton") {
            primaryButtonAction()
        }
        self.secondaryButtonViewModel = StandardButtonViewModel(titleKey: "app_disagreeButton") {
            secondaryButtonAction()
        }
    }
    
    func didAppear() {
        // Conforming to BaseViewModel
    }
    
    func didDismiss() {
        // Conforming to BaseViewModel
    }
}
