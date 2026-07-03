import DesignSystem
import GDSAnalytics
import Logging
import UIKit

struct UnlockScreenViewModel: BaseViewModel {
    let didAppear: DesignSystem.Action?
    let didDismiss: DesignSystem.Action? = nil
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    let backButtonTitle: GDSLocalisedString? = nil
    
    let primaryButtonAction: () -> Void
    let primaryButtonTitle: String = GDSLocalisedString(stringKey: "app_unlockButton").value
    let accessibilityLabel: GDSLocalisedString = GDSLocalisedString(stringKey: "app_loadingLabel", "app_nameString")
    
    init(analyticsService: OneLoginAnalyticsService,
         primaryButtonAction: @escaping () -> Void) {
        let analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.system,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        self.didAppear = .action({
            let screen = ScreenView(id: BiometricEnrolmentAnalyticsScreenID.unlock.rawValue,
                                    screen: BiometricEnrolmentAnalyticsScreen.unlock,
                                    titleKey: "one login unlock screen")
            analyticsService.trackScreen(screen)
        })
        
        self.primaryButtonAction = {
            let event = ButtonEvent(textKey: "app_unlockButton")
            analyticsService.logEvent(event)
            primaryButtonAction()
        }
    }
}
