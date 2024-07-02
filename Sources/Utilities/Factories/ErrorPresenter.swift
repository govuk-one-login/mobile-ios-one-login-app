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
        let viewModel = SignOutErrorViewModel(errorDescription: errorDescription,
                                              analyticsService: analyticsService) {
            action()
        }
        return GDSErrorViewController(viewModel: viewModel)
    }
    
    static func createSignoutWarning(analyticsService: AnalyticsService,
                                     action: @escaping () -> Void) -> GDSErrorViewController {
        let viewModel = SignOutWarningViewModel(analyticsService: analyticsService) {
            action()
        }
        return GDSErrorViewController(viewModel: viewModel)
    }
}
