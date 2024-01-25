import Authentication
import GDSCommon
import Logging

@available(iOS 14.0, *)
final class OnboardingViewControllerFactory {
    
    static func createAppAttestIntroViewController(analyticsService: AnalyticsService) -> AppAttestViewController {
        return AppAttestViewController()
    }
}
