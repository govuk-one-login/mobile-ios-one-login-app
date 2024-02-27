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
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_unlockScreenButton",
                                                               analyticsService: analyticsService) {
            primaryButtonAction()
        }
    }

    func didAppear() {
        let screen = ScreenView(screen: BiometricEnrollmentAnalyticsScreen.unlockScreen, titleKey: primaryButtonViewModel.title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() {
        // conforming to BaseViewModel
    }
    

}
