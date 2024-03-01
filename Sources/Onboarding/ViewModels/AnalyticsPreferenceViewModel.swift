import GDSCommon
import Logging
import UIKit

struct AnalyticsPreferenceViewModel: ModalInfoButtonsViewModel, BaseViewModel {
    let title: GDSLocalisedString = "app_acceptAnalyticsPreferences_title"
    let body: GDSLocalisedString = "acceptAnalyticsPreferences_body"
    let bodyTextColour: UIColor? = .label
    let primaryButtonViewModel: ButtonViewModel?
    let secondaryButtonViewModel: ButtonViewModel?
    let analyticsService: AnalyticsService
    let preventModalDismiss: Bool? = true
    
    var rightBarButtonTitle: GDSLocalisedString?
    var backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService,
         primaryButtonAction: @escaping () -> Void,
         secondaryButtonAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_agreeButton",
                                                               analyticsService: analyticsService) {
            primaryButtonAction()
        }
        self.secondaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_disagreeButton",
                                                                 icon: nil,
                                                                 analyticsService: analyticsService) {
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
