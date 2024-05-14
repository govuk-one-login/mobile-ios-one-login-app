import Logging

protocol AnalyticsCentral {
    var analyticsService: AnalyticsService { get set }
    var analyticsPreferenceStore: AnalyticsPreferenceStore { get set }
}
