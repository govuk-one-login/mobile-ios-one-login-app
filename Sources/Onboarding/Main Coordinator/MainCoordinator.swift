import Authentication
import Coordination
import Foundation
import GDSCommon
import Networking
import UIKit
import UserDetails

final class MainCoordinator: NSObject,
                             NavigationCoordinator {
    private let window: UIWindow
    var root: UINavigationController
    var activityIndicator: UIActivityIndicatorView = .init()
    var session: LoginSession
    
    init(window: UIWindow, root: UINavigationController, session: LoginSession) {
        self.window = window
        self.root = root
        self.session = session
    }
    
    func start() {
        let viewModel = OneLoginIntroViewModel {
            self.activityIndicator.startAnimating()
            
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
            
            self.session.present(configuration: configuration)
        }
        
        let viewController = IntroViewController(viewModel: viewModel)
        root.setViewControllers([viewController], animated: false)
    }
}
