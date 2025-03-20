import Foundation
import GDSAnalytics
import Logging
import Wallet

typealias OneLoginScreenType = Logging.ScreenType & GDSAnalytics.ScreenType

extension ScreenView: @retroactive LoggableScreenV2
where Screen: GDSAnalytics.ScreenType & CustomStringConvertible {
    public var name: String {
        screen.name
    }

    public var type: Screen {
        self.screen
    }
}

extension ErrorScreenView: @retroactive LoggableScreenV2
where Screen: GDSAnalytics.ScreenType & CustomStringConvertible {
    public var name: String {
        screen.name
    }

    public var type: Screen {
        screen
    }
}

extension EventName: @retroactive LoggableEvent { }

extension AnalyticsService {
    public func logEvent(_ event: Event) {
        logEvent(event.name,
                 parameters: event.parameters)
    }
    
    public func trackScreen<Screen: ScreenViewProtocol & LoggableScreenV2>(_ screen: Screen) {
        trackScreen(screen,
                    parameters: screen.parameters)
    }
}

extension UserDefaultsPreferenceStore: SessionBoundData {
    func delete() throws {
        hasAcceptedAnalytics = nil
    }
}

extension Dictionary where Key == String, Value == Any {
    static let oneLoginDefaults: Self = [
        "saved_doc_type": "undefined",
        "primary_publishing_organisation": "government digital service - digital identity",
        "organisation": "<OT1056>",
        "taxonomy_level1": "one login mobile application",
        "language": "\(NSLocale.current.identifier.prefix(2))"
    ]
}
