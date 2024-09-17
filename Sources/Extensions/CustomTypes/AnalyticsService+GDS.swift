import GDSAnalytics
import Logging

typealias ScreenType = Logging.ScreenType & GDSAnalytics.ScreenType

enum AppTaxonomy: String {
    case login
    case home
    case wallet
    case profile
    case reauth = "re auth"
}

extension AnalyticsService {
    public func logEvent(_ event: Event) {
        logEvent(event.name,
                 parameters: event.parameters)
    }
    
    public func trackScreen<Screen>(_ screen: Screen)
    where Screen: ScreenViewProtocol & LoggableScreenV2 {
        trackScreen(screen,
                    parameters: screen.parameters)
    }
    
    mutating func setAdditionalParameters(appTaxonomy: AppTaxonomy) {
        var taxonomyLevel3: String {
            if appTaxonomy == .reauth {
                "re auth"
            } else if appTaxonomy == .profile {
                "my profile"
            } else {
                "undefined"
            }
        }
        additionalParameters = additionalParameters.merging([
            "taxonomy_level2": appTaxonomy == .reauth ? AppTaxonomy.login.rawValue : appTaxonomy.rawValue,
            "taxonomy_level3": taxonomyLevel3
        ]) { $1 }
    }
}
