import Authentication
import GDSCommon
import Logging
import UIKit

final class ViewControllerFactory {
    let analyticsService: AnalyticsService
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    func createIntroViewController(session: LoginSession) -> IntroViewController {
        let viewModel = OneLoginIntroViewModel(analyticsService: analyticsService) {
            let url = URL.oneLoginAuthorize
            let configuration = LoginSessionConfiguration.oneLogin(authorizeEndpoint: url)
            session.present(configuration: configuration)
        }
        
        return IntroViewController(viewModel: viewModel)
    }
}
