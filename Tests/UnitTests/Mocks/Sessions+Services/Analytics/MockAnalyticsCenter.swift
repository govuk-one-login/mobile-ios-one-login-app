import Logging
@testable import OneLogin

final class MockAnalyticsCenter: AnalyticsCentral {
    let analyticsService: AnalyticsService
    var analyticsPreferenceStore: AnalyticsPreferenceStore
    
    init(analyticsService: AnalyticsService,
         analyticsPreferenceStore: AnalyticsPreferenceStore) {
        self.analyticsService = analyticsService
        self.analyticsPreferenceStore = analyticsPreferenceStore
    }
}
