import GDSCommon
import Logging

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
    
    static func createNetworkConnectionError(analyticsService: AnalyticsService,
                                             action: @escaping () -> Void) -> GDSErrorViewController {
        let viewModel = NetworkConnectionErrorViewModel(analyticsService: analyticsService) {
            action()
        }
        return GDSErrorViewController(viewModel: viewModel)
    }
    
    
    static func createSignoutError(errorDescription: String,
                                   analyticsService: AnalyticsService,
                                   action: @escaping () -> Void) -> GDSErrorViewController {
        let viewModel = SignoutErrorViewModel(errorDescription: errorDescription,
                                                    analyticsService: analyticsService) {
            action()
        }
        return GDSErrorViewController(viewModel: viewModel)
    }
}
