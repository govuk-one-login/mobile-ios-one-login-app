import Logging
import XCTest

final class MockAnalyticsService: OneLoginAnalyticsService {
    var additionalParameters = [String: Any]()
    
    private(set) var screensVisited = [String]()
    private(set) var screenParamsLogged = [String: String]()
    private(set) var eventsLogged = [String]()
    private(set) var eventsParamsLogged = [String: String]()
    private(set) var crashesLogged = [NSError]()
    
    var hasAcceptedAnalytics: Bool?
    
    func trackScreen(_ screen: LoggableScreen, title: String?) {
        screensVisited.append(screen.name)
    }
    
    func trackScreen(_ screen: LoggableScreen, parameters: [String: Any] = [:]) {
        screensVisited.append(screen.name)
        
        guard let parameters = parameters as? [String: String] else {
            XCTFail("Non-string parameters were logged")
            return
        }
        
        screenParamsLogged = parameters
    }
    
    func trackScreen(_ screen: LoggableScreenV2, parameters: [String: Any]) {
        screensVisited.append(screen.name)
        
        guard let parameters = parameters as? [String: String] else {
            XCTFail("Non-string parameters were logged")
            return
        }
        
        screenParamsLogged = parameters
    }
    
    
    func logEvent(_ event: LoggableEvent, parameters: [String: Any]) {
        eventsLogged.append(event.name)
        
        guard let parameters = parameters as? [String: String] else {
            XCTFail("Non-string parameters were logged")
            return
        }
        
        eventsParamsLogged = parameters
    }
    
    func logCrash(_ crash: NSError) {
        crashesLogged.append(crash)
    }
    
    func logCrash(_ crash: Error) {
        crashesLogged.append(crash as NSError)
    }
    
    func grantAnalyticsPermission() {
        hasAcceptedAnalytics = true
    }
    
    func denyAnalyticsPermission() {
        hasAcceptedAnalytics = false
    }
}
