import GDSCommon
import Logging

@MainActor
final class ErrorPresenter {
    static func createGenericError(errorDescription: String,
                                   analyticsService: AnalyticsService,
                                   action: @escaping () -> Void) -> GDSErrorViewController {
        let viewModel = GenericErrorViewModel(errorDescription: errorDescription,
                                              analyticsService: analyticsService) {
            action()
        }
        return GDSErrorViewController(viewModel: viewModel)
    }
    
    static func createUnableToLoginError(errorDescription: String,
                                         analyticsService: AnalyticsService,
                                         action: @escaping () -> Void) -> GDSErrorViewController {
        let viewModel = UnableToLoginErrorViewModel(errorDescription: errorDescription,
                                                    analyticsService: analyticsService) {
            action()
        }
        return GDSErrorViewController(viewModel: viewModel)
    }
    
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
