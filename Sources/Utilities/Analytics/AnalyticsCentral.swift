import Logging

protocol AnalyticsCentral {
    var analyticsService: AnalyticsService { get }
    var analyticsPreferenceStore: AnalyticsPreferenceStore { get set }
}
