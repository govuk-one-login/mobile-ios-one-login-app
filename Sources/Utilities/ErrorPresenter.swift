import GDSCommon
import Logging

final class ErrorPresenter {
    static func createGenericError(analyticsService: AnalyticsService,
                                   action: @escaping () -> Void) -> GDSErrorViewController {
        let viewModel = GenericErrorViewModel(analyticsService: analyticsService) {
            action()
        }
        return GDSErrorViewController(viewModel: viewModel)
    }
    
    static func createUnableToLoginError(analyticsService: AnalyticsService,
                                         action: @escaping () -> Void) -> GDSErrorViewController {
        let viewModel = UnableToLoginErrorViewModel(analyticsService: analyticsService) {
            action()
        }
        return GDSErrorViewController(viewModel: viewModel)
    }
}
