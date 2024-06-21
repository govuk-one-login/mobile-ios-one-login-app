import Logging
#if NOW
@testable import OneLoginNOW
#else
@testable import OneLogin
#endif


final class MockAnalyticsCenter: AnalyticsCentral {
    var analyticsService: AnalyticsService
    var analyticsPreferenceStore: AnalyticsPreferenceStore
    
    init(analyticsService: AnalyticsService,
         analyticsPreferenceStore: AnalyticsPreferenceStore) {
        self.analyticsService = analyticsService
        self.analyticsPreferenceStore = analyticsPreferenceStore
    }
}
