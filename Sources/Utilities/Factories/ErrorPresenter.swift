import GDSCommon
import Logging

@MainActor
final class ErrorPresenter {
    static func createSignOutError(errorDescription: String,
                                   analyticsService: AnalyticsService,
                                   action: @escaping () -> Void) -> GDSErrorViewController {
        let viewModel = SignOutErrorViewModel(errorDescription: errorDescription,
                                              analyticsService: analyticsService) {
            action()
        }
        return GDSErrorViewController(viewModel: viewModel)
    }
}
