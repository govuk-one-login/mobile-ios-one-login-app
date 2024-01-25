import Authentication
import GDSCommon
import Logging

@available(iOS 14.0, *)
final class OnboardingViewControllerFactory {
    static func createIntroViewController(analyticsService: AnalyticsService,
                                          action: @escaping () -> Void) -> IntroViewController {
        let viewModel = OneLoginIntroViewModel(analyticsService: analyticsService) {
            action()
        }
        return IntroViewController(viewModel: viewModel)
    }
    
    static func createAppAttestIntroViewController(analyticsService: AnalyticsService) -> AppAttestViewController {
        //        let viewModel = OneLoginIntroViewModel(analyticsService: analyticsService) {
        //            action()
        //        }
        return AppAttestViewController()
    }
}
