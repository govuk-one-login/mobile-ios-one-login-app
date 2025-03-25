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
