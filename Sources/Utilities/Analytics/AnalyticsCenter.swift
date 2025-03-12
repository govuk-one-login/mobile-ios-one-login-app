import Foundation
import Logging

final class AnalyticsCenter: AnalyticsCentral {
    var analyticsService: AnalyticsService
    var analyticsPreferenceStore: AnalyticsPreferenceStore
    
    init(analyticsService: AnalyticsService,
         analyticsPreferenceStore: AnalyticsPreferenceStore) {
        self.analyticsService = analyticsService
        self.analyticsPreferenceStore = analyticsPreferenceStore
        setStartingParameters()
    }
    
    private func setStartingParameters() {
        analyticsService.additionalParameters = [
            "saved_doc_type": "undefined",
            "primary_publishing_organisation": "government digital service - digital identity",
            "organisation": "<OT1056>",
            "taxonomy_level1": "one login mobile application",
            "language": "\(NSLocale.current.identifier.prefix(2))"
        ]
        analyticsService.setAdditionalParameters(appTaxonomy: .login)
    }
}

extension AnalyticsCenter: SessionBoundData {
    func delete() throws {
        analyticsPreferenceStore.hasAcceptedAnalytics = nil
    }
}
