import Logging

protocol AnalyticsCentral: AnyObject {
    var analyticsService: AnalyticsService { get set }
    var analyticsPreferenceStore: AnalyticsPreferenceStore { get set }
}

extension AnalyticsCentral {
    func resetAnalyticsPreferences() {
        analyticsPreferenceStore.hasAcceptedAnalytics = nil
    }
}
