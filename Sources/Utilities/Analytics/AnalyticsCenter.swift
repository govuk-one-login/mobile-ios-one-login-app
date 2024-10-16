import Foundation
import Logging

final class AnalyticsCenter: AnalyticsCentral {
    var analyticsService: AnalyticsService
    var analyticsPreferenceStore: AnalyticsPreferenceStore
    
    init(analyticsService: AnalyticsService,
         analyticsPreferenceStore: AnalyticsPreferenceStore) {
        self.analyticsService = analyticsService
        self.analyticsPreferenceStore = analyticsPreferenceStore
        setAdditionalParameters()
    }
    
    private func setAdditionalParameters() {
        analyticsService.additionalParameters = [
            "saved_doc_type": "undefined",
            "primary_publishing_organisation": "government digital service - digital identity",
            "organisation": "<OT1056>",
            "taxonomy_level1": "one login mobile application",
            "taxonomy_level2": "login",
            "taxonomy_level3": "undefined",
            "language": "\(NSLocale.current.identifier.prefix(2))"
        ]
    }
}

extension AnalyticsCenter: SessionBoundData {
    func delete() throws {
        analyticsPreferenceStore.hasAcceptedAnalytics = nil
    }
}
