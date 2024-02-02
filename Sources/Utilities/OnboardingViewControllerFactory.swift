import Authentication
import GDSCommon
import Logging

final class OnboardingViewControllerFactory {
    static func createIntroViewController(analyticsService: AnalyticsService,
                                          action: @escaping () -> Void) -> IntroViewController {
        let viewModel = OneLoginIntroViewModel(analyticsService: analyticsService) {
            action()
        }
        return IntroViewController(viewModel: viewModel)
    }
    
    static func createPasscodeInformationScreen(analyticsService: AnalyticsService,
                                                action: @escaping () -> Void) -> GDSInformationViewController {
        let viewModel = PasscodeInformationViewModel(analyticsService: analyticsService) {
            action()
        }
        return GDSInformationViewController(viewModel: viewModel)
    }
}
