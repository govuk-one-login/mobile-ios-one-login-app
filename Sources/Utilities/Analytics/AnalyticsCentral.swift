import Logging

protocol AnalyticsCentral: AnyObject {
    var analyticsService: OneLoginAnalyticsService { get set }
    var analyticsPreferenceStore: AnalyticsPreferenceStore { get set }
}

extension AnalyticsCentral {
    var analyticsPermissionsNotSet: Bool {
        analyticsPreferenceStore.hasAcceptedAnalytics == nil
    }
}
