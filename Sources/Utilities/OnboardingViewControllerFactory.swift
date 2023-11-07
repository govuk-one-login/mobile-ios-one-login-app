import Authentication
import GDSCommon
import Logging

final class OnboardingViewControllerFactory {
    static func createIntroViewController(analyticsService: AnalyticsService, session: LoginSession) -> IntroViewController {
        let viewModel = OneLoginIntroViewModel(analyticsService: analyticsService) {
            let configuration = LoginSessionConfiguration.oneLogin
            session.present(configuration: configuration)
        }
        return IntroViewController(viewModel: viewModel)
    }
}
