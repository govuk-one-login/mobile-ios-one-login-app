import GDSAnalytics
import Logging

extension AnalyticsService {
    public func logEvent(_ event: Event) {
        logEvent(event.name,
                 parameters: event.parameters)
    }
    
    public func trackScreen<View: ScreenViewProtocol>(_ view: View)
    where View.Screen: LoggableScreen {
        trackScreen(view.screen,
                    parameters: view.parameters)
    }
}

extension EventName: LoggableEvent { }
