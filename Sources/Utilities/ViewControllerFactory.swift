import Authentication
import GDSCommon
import UIKit

final class ViewControllerFactory {
    func createIntroViewController(session: LoginSession) -> IntroViewController {
        let viewModel = OneLoginIntroViewModel {
            let url = URL.oneLoginAuthorize
            let configuration: LoginSessionConfiguration = LoginSessionConfiguration.oneLogin(url: url)
            session.present(configuration: configuration)
        }
        
        return IntroViewController(viewModel: viewModel)
    }
}
