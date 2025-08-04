import Logging
@testable import OneLogin
import XCTest

final class MockAnalyticsService: OneLoginAnalyticsService {
    var analyticsPreferenceStore: AnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
    
    var additionalParameters = [String: Any]()
    
    private(set) var screenViews = [any LoggableScreenV2]()
    private(set) var screensVisited = [String]()
    private(set) var screenParamsLogged = [String: String]()
    private(set) var eventsLogged = [String]()
    private(set) var eventsParamsLogged = [String: String]()
    private(set) var crashesLogged = [NSError]()
    
    var hasAcceptedAnalytics: Bool?
    
    func addingAdditionalParameters(_ additionalParameters: [String: Any]) -> Self {
        self.additionalParameters = additionalParameters
        return self
    }
    
    func trackScreen(_ screen: LoggableScreen, parameters: [String: Any] = [:]) {
        screensVisited.append(screen.name)
        
        guard let parameters = parameters as? [String: String] else {
            XCTFail("Non-string parameters were logged")
            return
        }
        
        screenParamsLogged = parameters
    }
    
    func trackScreen(_ screen: any LoggableScreenV2, parameters: [String: Any]) {
        screenViews.append(screen)
        
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
