import GDSAnalytics
import Logging

typealias ScreenType = Logging.ScreenType & GDSAnalytics.ScreenType

enum AppTaxonomy: String {
    case login
    case home
    case wallet
    case profile
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
        additionalParameters = additionalParameters.merging([
            "taxonomy_level2": appTaxonomy.rawValue,
            "taxonomy_level3": appTaxonomy == .profile ? "my profile" : "undefined"
        ]) { $1 }
    }
}
