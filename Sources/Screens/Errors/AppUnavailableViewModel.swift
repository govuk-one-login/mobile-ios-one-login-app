import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct AppUnavailableViewModel: GDSInformationViewModelV2,
                                BaseViewModel {
    let image: String = "exclamationmark.circle"
    let imageWeight: UIFont.Weight? = .regular
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 100
    let title: GDSLocalisedString = "app_appUnavailableTitle"
    let body: GDSLocalisedString? = "app_appUnavailableBody"
    let analyticsService: AnalyticsService
    
    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true
    
    init(analyticsService: AnalyticsService) {
        var tempAnalyticsService = analyticsService
        tempAnalyticsService.setAdditionalParameters(appTaxonomy: .system)
        self.analyticsService = tempAnalyticsService
    }
    
    func didAppear() {
        let screen = ErrorScreenView(id: ErrorAnalyticsScreenID.appUnavailable.rawValue,
                                     screen: ErrorAnalyticsScreen.appUnavailable,
                                     titleKey: title.stringKey)
        analyticsService.trackScreen(screen)
    }
    
    func didDismiss() { /* Conforming to BaseViewModel */ }
}
