import GDSAnalytics
import Logging

public typealias OneLoginScreenType = GDSAnalytics.ScreenType

extension ScreenView: @retroactive LoggableScreen where Screen: OneLoginScreenType {
    public var name: String {
        title
    }

    public var type: Screen {
        screen
    }
}

extension ErrorScreenView: @retroactive LoggableScreen where Screen: OneLoginScreenType {
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
    
    public func trackScreen<Screen: ScreenViewProtocol & LoggableScreen>(_ screen: Screen) {
        trackScreen(screen,
                    parameters: screen.parameters)
    }
}

extension UserDefaultsPreferenceStore: SessionBoundData {
    func clearSessionData() throws {
        hasAcceptedAnalytics = nil
    }
}
