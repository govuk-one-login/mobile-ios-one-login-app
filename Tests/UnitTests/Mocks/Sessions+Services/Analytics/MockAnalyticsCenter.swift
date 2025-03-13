import Logging
@testable import OneLogin

final class MockAnalyticsCenter: AnalyticsCentral {
    var analyticsService: OneLoginAnalyticsService
    var analyticsPreferenceStore: AnalyticsPreferenceStore
    
    init(analyticsService: OneLoginAnalyticsService,
         analyticsPreferenceStore: AnalyticsPreferenceStore) {
        self.analyticsService = analyticsService
        self.analyticsPreferenceStore = analyticsPreferenceStore
    }
}
