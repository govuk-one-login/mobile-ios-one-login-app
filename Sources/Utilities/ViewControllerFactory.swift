import Authentication
import GDSCommon
import UIKit

final class ViewControllerFactory {
    func createIntroViewController(session: LoginSession) -> IntroViewController {
        let viewModel = OneLoginIntroViewModel {
            
            let url = URL(string: "https://oidc.integration.account.gov.uk/authorize")!
            let configuration = LoginSessionConfiguration(authorizationEndpoint: url,
                                                          responseType: .code,
                                                          scopes: [.openid, .email, .phone, .offline_access],
                                                          clientID: "6ttkBTo3Yk2ifegc6sHSDp4qwY",
                                                          prefersEphemeralWebSession: false,
                                                          redirectURI: "https://app-login-spike-www.review-b.dev.account.gov.uk/dca/app/redirect",
                                                          nonce: "aEwkamaos5B",
                                                          viewThroughRate: "[Cl.Cm.P0]",
                                                          locale: .en)
            
            session.present(configuration: configuration)
        }
        
        return IntroViewController(viewModel: viewModel)
    }
}
