import Logging

final class AnalyticsCentre: AnalyticsCentral {
    let analyticsService: AnalyticsService
    var analyticsPreferenceStore: AnalyticsPreferenceStore
    
    init(analyticsService: AnalyticsService,
         analyticsPreferenceStore: AnalyticsPreferenceStore) {
        self.analyticsService = analyticsService
        self.analyticsPreferenceStore = analyticsPreferenceStore
    }
}
