import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct AppUnavailableViewModel: GDSInformationViewModel, BaseViewModel {
    let image: String = "exclamationmark.circle"
    let imageWeight: UIFont.Weight? = .regular
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 100
    let title: GDSLocalisedString = "app_appUnavailableTitle"
    let body: GDSLocalisedString? = "app_appUnavailableBody"
    let footnote: GDSLocalisedString? = nil
    let analyticsService: AnalyticsService

    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true

    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }

    func didAppear() { /* TODO DCMAW-9612: create screen, send event */ }

    func didDismiss() { /* Conforming to BaseViewModel */ }
}
