import Logging

protocol AnalyticsCentral: AnyObject {
    var analyticsService: AnalyticsService { get set }
    var analyticsPreferenceStore: AnalyticsPreferenceStore { get set }
}

extension AnalyticsCentral {
    var analyticsPermissionsNotSet: Bool {
        analyticsPreferenceStore.hasAcceptedAnalytics == nil
    }
    
    func resetAnalyticsPreferences() {
        analyticsPreferenceStore.hasAcceptedAnalytics = nil
    }
}
