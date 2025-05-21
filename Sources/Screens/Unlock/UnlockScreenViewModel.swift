import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct UnlockScreenViewModel: BaseViewModel {
    let analyticsService: OneLoginAnalyticsService
    let primaryButtonViewModel: ButtonViewModel
    let accessibilityLabel: GDSLocalisedString = GDSLocalisedString(stringKey: "app_loadingLabel")
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService,
         primaryButtonAction: @escaping () -> Void ) {
        self.analyticsService = analyticsService
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_unlockButton",
                                                               analyticsService: analyticsService) {
            primaryButtonAction()
        }
    }
    
    func didAppear() {
        let screen = ScreenView(id: BiometricEnrolmentAnalyticsScreenID.unlock.rawValue,
                                screen: BiometricEnrolmentAnalyticsScreen.unlock,
                                titleKey: "one login unlock screen")
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* conforming to BaseViewModel */ }
}
