import Logging

final class AnalyticsCenter: AnalyticsCentral {
    let analyticsService: AnalyticsService
    var analyticsPreferenceStore: AnalyticsPreferenceStore
    
    init(analyticsService: AnalyticsService,
         analyticsPreferenceStore: AnalyticsPreferenceStore) {
        self.analyticsService = analyticsService
        self.analyticsPreferenceStore = analyticsPreferenceStore
        setAdditionalParameters()
    }
    
    private func setAdditionalParameters() {
        analyticsService.additionalParameters = [
            "primary_publishing_organisation": "government digital service - digital identity",
            "organisation": "<OT1056>",
            "taxonomy_level1": "one login mobile application",
            "taxonomy_level2": "login"
        ]
    }
}
