import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct UnlockScreenViewModel: BaseViewModel {
    let analyticsService: AnalyticsService
    let primaryButtonViewModel: ButtonViewModel
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true

    init(analyticsService: AnalyticsService,
         primaryButtonAction: @escaping () -> Void ) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_unlockButton",
                                                               analyticsService: analyticsService) {
            primaryButtonAction()
        }
    }

    func didAppear() {

    }
    
    func didDismiss() {
        // conforming to BaseViewModel
    }
}
