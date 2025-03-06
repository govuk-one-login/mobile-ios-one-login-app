import GDSAnalytics
import GDSCommon
import Logging
import UIKit

struct OneLoginTileViewModel: GDSContentTileViewModel,
                              GDSContentTileViewModelWithBody,
                              GDSContentTileViewModelWithSecondaryButton {
    let title: GDSLocalisedString = "app_oneLoginCardTitle"
    let body: GDSLocalisedString = "app_oneLoginCardBody"
    let showSeparatorLine: Bool = true
    let secondaryButtonViewModel: ButtonViewModel
    let backgroundColour: UIColor? = .secondarySystemGroupedBackground
    
    init(analyticsService: AnalyticsService,
         action: @escaping () -> Void) {
        let event = LinkEvent(textKey: "app_oneLoginCardLink",
                              linkDomain: "https://gov.uk/using-your-gov-uk-one-login",
                              external: .false)
        self.secondaryButtonViewModel = AnalyticsButtonViewModel(titleKey: "app_oneLoginCardLink",
                                                                 icon: .external,
                                                                 analyticsService: analyticsService,
                                                                 analyticsEvent: event) {
            action()
        }
    }
}

extension GDSContentTileViewModel where Self == OneLoginTileViewModel {
    static func oneLoginCard(analyticsService: AnalyticsService,
                             urlOpener: URLOpener) -> OneLoginTileViewModel {
        OneLoginTileViewModel(analyticsService: analyticsService) {
            urlOpener.open(url: AppEnvironment.manageAccountURL)
        }
    }
}
