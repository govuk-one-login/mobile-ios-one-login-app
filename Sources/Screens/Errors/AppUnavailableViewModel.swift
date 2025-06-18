import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct AppUnavailableViewModel: GDSCentreAlignedViewModel,
                                GDSCentreAlignedViewModelWithImage,
                                BaseViewModel {
    let image: String = "exclamationmark.circle"
    let imageWeight: UIFont.Weight? = .regular
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 100
    let title: GDSLocalisedString = "app_appUnavailableTitle"
    let body: GDSLocalisedString? = GDSLocalisedString(stringKey: "app_appUnavailableBody",
                                                       "app_nameString")
    let analyticsService: OneLoginAnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: OneLoginAnalyticsService) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.system
        ])
    }
    
    func didAppear() {
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.appUnavailable.rawValue,
                                     screen: ErrorAnalyticsScreen.appUnavailable,
                                     titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* Conforming to BaseViewModel */ }
}
