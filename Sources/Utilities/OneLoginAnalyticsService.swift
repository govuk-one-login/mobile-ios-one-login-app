import Logging
import Foundation

class OneLoginAnalyticsService: AnalyticsService {
    
    var additionalParameters = [String : Any]()
    
    func grantAnalyticsPermission() { }
    
    func denyAnalyticsPermission() { }
    
    func logEvent(_ event: LoggableEvent, parameters: [String : Any]) { }
    
    func logCrash(_ crash: NSError) { }
    
    func trackScreen(_ screen: LoggableScreen, parameters: [String : Any]) { }
}
