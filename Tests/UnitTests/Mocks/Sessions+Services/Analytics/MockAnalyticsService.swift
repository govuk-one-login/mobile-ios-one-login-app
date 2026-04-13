import Logging
@testable import OneLogin
import XCTest

final class MockAnalyticsService: OneLoginAnalyticsService {
    var analyticsPreferenceStore: AnalyticsPreferenceStore = MockAnalyticsPreferenceStore()
    
    var additionalParameters = [String: Any]()
    
    private(set) var screenViews = [any LoggableScreen]()
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

    func trackScreen(_ screen: any LoggableScreen, parameters: [String: Any]) {
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

final class MockAnalyticsServiceExpectation: OneLoginAnalyticsService {
    var analyticsPreferenceStore: AnalyticsPreferenceStore {
        mockAnalyticsService.analyticsPreferenceStore
    }

    var additionalParameters: [String : Any] {
        get {
            mockAnalyticsService.additionalParameters
        }
        set {
            mockAnalyticsService.additionalParameters = newValue
        }
    }

    var crashesLogged: [NSError] {
        mockAnalyticsService.crashesLogged
    }
    
    let mockAnalyticsService = MockAnalyticsService()
    let expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func addingAdditionalParameters(_ additionalParameters: [String : Any]) -> Self {
        _ = mockAnalyticsService.addingAdditionalParameters(additionalParameters)
        return self
    }
    
    func logCrash(_ crash: NSError) {
        mockAnalyticsService.logCrash(crash)
    }
    
    func logCrash(_ crash: any Error) {
        mockAnalyticsService.logCrash(crash)
        expectation.fulfill()
    }
    
    func trackScreen(_ screen: any LoggableScreen, parameters: [String : Any]) {
        mockAnalyticsService.trackScreen(screen, parameters: parameters)
    }
    
    func logEvent(_ event: any Logging.LoggableEvent, parameters: [String : Any]) {
        mockAnalyticsService.logEvent(event)
    }
}
