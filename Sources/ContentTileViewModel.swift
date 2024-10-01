import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct ContentTileViewModel: GDSContentTileViewModel, GDSContentTileViewModelWithBody, GDSContentTileViewModelWithSecondaryButton {
    let title: GDSLocalisedString = "app_yourServicesCardTitle"
    let body: GDSLocalisedString = "app_yourServicesCardBody"
    let showSeparatorLine: Bool = true
    let secondaryButtonViewModel: ButtonViewModel
    let backgroundColour: UIColor? = .systemBackground
    let analyticsService: AnalyticsService
    
    init(analyticsService: AnalyticsService,
         action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        let event = LinkEvent(textKey: "app_yourServicesCardLink",
                              linkDomain: AppEnvironment.yourServicesLink,
                              external: .false)
        self.secondaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_yourServicesCardLink",
                                                               analyticsService: analyticsService,
                                                                 analyticsEvent: event) {
            action()
        }
    }
}
