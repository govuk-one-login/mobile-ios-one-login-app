import CRIOrchestrator
import Logging
import Wallet

protocol AnalyticsCentral: AnyObject {
    var analyticsService: OneLoginAnalyticsService { get set }
    var analyticsPreferenceStore: AnalyticsPreferenceStore { get set }
}

extension AnalyticsCentral {
    var analyticsPermissionsNotSet: Bool {
        analyticsPreferenceStore.hasAcceptedAnalytics == nil
    }
}
