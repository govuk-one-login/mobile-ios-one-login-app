import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct ServicesTileViewModel: GDSContentTileViewModel,
                              GDSContentTileViewModelWithBody,
                              GDSContentTileViewModelWithSecondaryButton {
    let title: GDSLocalisedString = "app_yourServicesCardTitle"
    let body: GDSLocalisedString = "app_yourServicesCardBody"
    let showSeparatorLine: Bool = true
    let secondaryButtonViewModel: ButtonViewModel
    let backgroundColour: UIColor? = .secondarySystemGroupedBackground
    
    init(analyticsService: AnalyticsService,
         action: @escaping () -> Void) {
        let event = LinkEvent(textKey: "app_yourServicesCardLink",
                              linkDomain: AppEnvironment.yourServicesLink,
                              external: .false)
        self.secondaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_yourServicesCardLink",
                                                                 icon: .external,
                                                                 analyticsService: analyticsService,
                                                                 analyticsEvent: event) {
            action()
        }
    }
}

extension GDSContentTileViewModel where Self == ServicesTileViewModel {
    static func yourServices(analyticsService: AnalyticsService, urlOpener: URLOpener) -> ServicesTileViewModel {
        ServicesTileViewModel(analyticsService: analyticsService) {
            urlOpener.open(url: AppEnvironment.yourServicesURL)
        }
    }
}
 
