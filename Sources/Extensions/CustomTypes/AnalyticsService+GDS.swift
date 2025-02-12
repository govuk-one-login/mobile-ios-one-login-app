import GDSAnalytics
import Logging

typealias ScreenType = Logging.ScreenType & GDSAnalytics.ScreenType

enum AppTaxonomy: String {
    case system = "app system"
    case login
    case home
    case wallet
    case settings
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
        let (taxonomyLevel2, taxonomyLevel3) = {
            switch appTaxonomy {
            case .reauth:
                (AppTaxonomy.login.rawValue, appTaxonomy.rawValue)
            case .settings:
                (appTaxonomy.rawValue, "my \(appTaxonomy.rawValue)")
            default:
                (appTaxonomy.rawValue, "undefined")
            }
        }()
        additionalParameters = additionalParameters.merging([
            "taxonomy_level2": taxonomyLevel2,
            "taxonomy_level3": taxonomyLevel3
        ]) { $1 }
    }
}
