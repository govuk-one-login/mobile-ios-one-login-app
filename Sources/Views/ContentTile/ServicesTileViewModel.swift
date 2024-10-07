import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct ServicesTileViewModel: GDSContentTileViewModel, GDSContentTileViewModelWithBody, GDSContentTileViewModelWithSecondaryButton {
    let title: GDSLocalisedString = "app_yourServicesCardTitle"
    let body: GDSLocalisedString = "app_yourServicesCardBody"
    let showSeparatorLine: Bool = true
    let secondaryButtonViewModel: ButtonViewModel
    let backgroundColour: UIColor? = .secondarySystemGroupedBackground
    let analyticsService: AnalyticsService
    
    init(analyticsService: AnalyticsService,
         action: @escaping () -> Void) {
        self.analyticsService = analyticsService
        let event = LinkEvent(textKey: "app_yourServicesCardLink",
                              linkDomain: AppEnvironment.yourServicesLink,
                              external: .false)
        self.secondaryButtonViewModel = AnalyticsButtonViewModel(titleKey: title.stringKey,
                                                                 icon: .external,
                                                                 analyticsService: analyticsService,
                                                                 analyticsEvent: event) {
            action()
        }
    }
}

extension GDSContentTileViewModel where Self == ServicesTileViewModel {
    static func yourServices(analyticsService: AnalyticsService, urlOpener: URLOpener) -> GDSContentTileViewModel {
        ServicesTileViewModel(analyticsService: analyticsService) {
            urlOpener.open(url: AppEnvironment.yourServicesURL)
        }
    }
}
 
