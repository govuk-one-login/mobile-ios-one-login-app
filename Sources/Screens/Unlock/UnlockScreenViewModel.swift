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
        // ScreenView is being sent in SceneLifecycle.promptToUnlock
        // so that sending the app to the background and resuming doesn't
        // break the journey and sends to GA4
    }
    
    func didDismiss() {
        // conforming to BaseViewModel
    }
}
