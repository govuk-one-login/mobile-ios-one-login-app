import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct ContentTileViewModel: GDSContentTileViewModel, GDSContentTileViewModelWithBody, GDSContentTileViewModelWithSecondaryButton {
    var title: GDSLocalisedString = "app_yourServicesCardTitle"
    var body: GDSLocalisedString = "app_yourServicesCardBody"
    var showSeparatorLine: Bool = true
    var secondaryButtonViewModel: ButtonViewModel
    var backgroundColour: UIColor? = .systemBackground
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
