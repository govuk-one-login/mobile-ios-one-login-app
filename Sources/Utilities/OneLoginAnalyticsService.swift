import Foundation
import Logging

final class OneLoginAnalyticsService: AnalyticsService {
    var additionalParameters = [String: Any]()
    
    func grantAnalyticsPermission() {
        // empty in lieu of analytics tickets
    }
    
    func denyAnalyticsPermission() {
        // empty in lieu of analytics tickets
    }
    
    func logEvent(_ event: LoggableEvent, parameters: [String: Any]) {
        // empty in lieu of analytics tickets
    }
    
    func logCrash(_ crash: NSError) {
        // empty in lieu of analytics tickets
    }
    
    func trackScreen(_ screen: LoggableScreen, parameters: [String: Any]) {
        // empty in lieu of analytics tickets
    }
    
    func trackScreen(_ screen: Logging.LoggableScreenV2, parameters: [String: Any]) {
        // empty in lieu of analytics tickets
    }
}
