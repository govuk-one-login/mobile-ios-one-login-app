import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct UpdateAppViewModel: GDSInformationViewModel, BaseViewModel {
    let title: GDSLocalisedString = "app_updateApp_Title"
    let body: GDSLocalisedString? = "app_updateApp_body1"
    let footnote: GDSLocalisedString? = "app_updateApp_body2"
    let image: String = "exclamationmark.arrow.circlepath"
    let imageWeight: UIFont.Weight? = nil
    let imageColour: UIColor? = nil
    let imageHeightConstraint: CGFloat? = 44
    let primaryButtonViewModel: ButtonViewModel
    let secondaryButtonViewModel: ButtonViewModel? = nil
    let analyticsService: AnalyticsService

    let rightBarButtonTitle: GDSLocalisedString? = nil
    let backButtonIsHidden: Bool = true

    init(analyticsService: AnalyticsService, action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        // TODO DCMAW-9612: add event for clicking the link (LinkEvent most likely).
        // update titleKey and action in `primaryButtonViewModel`
        self.primaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "",
                                                               analyticsService: analyticsService) {
            //action should open AppStore
            action()
        }
    }

    func didAppear() {
        // TODO DCMAW-9612: create screen, send event
    }

    func didDismiss() { /* Conforming to BaseViewModel */ }
}
