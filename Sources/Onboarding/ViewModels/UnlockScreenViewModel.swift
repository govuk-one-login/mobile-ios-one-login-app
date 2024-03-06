import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct UnlockScreenViewModel: BaseViewModel {
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    let primaryButtonViewModel: ButtonViewModel
    let analyticsService: AnalyticsService

    init(analyticsService: AnalyticsService,
         primaryButtonAction: @escaping () -> Void ) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_unlockButton",
                                                               analyticsService: analyticsService) {
            primaryButtonAction()
        }
    }

    func didAppear() {
        let screen = ScreenView(screen: BiometricEnrollmentAnalyticsScreen.unlockScreen, titleKey: "unlock screen")
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() {
        // conforming to BaseViewModel
    }
}
