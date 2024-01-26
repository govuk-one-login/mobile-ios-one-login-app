import GDSCommon
import Logging

final class InformationScreenPresenter {
    static func createPasscodeInformationScreen(analyticsService: AnalyticsService,
                                                action: @escaping () -> Void) -> GDSInformationController {
        let viewModel = PasscodeInformationViewModel(analyticsService: analyticsService) {
            action()
        }
        return GDSInformationController(viewModel: viewModel)
    }
}
