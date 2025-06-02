import GDSAnalytics
import Logging
import Wallet

public typealias OneLoginScreenType = GDSAnalytics.ScreenType

extension ScreenView: @retroactive LoggableScreenV2 where Screen: OneLoginScreenType {
    public var name: String {
        title
    }

    public var type: Screen {
        screen
    }
}

extension ErrorScreenView: @retroactive LoggableScreenV2 where Screen: OneLoginScreenType {
    public var name: String {
        title
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
