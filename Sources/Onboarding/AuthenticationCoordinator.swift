import Authentication
import Coordination
import UIKit

final class AuthenticationCoordinator: NSObject,
                                       ChildCoordinator,
                                       NavigationCoordinator {
    var root: UINavigationController
    var parentCoordinator: ParentCoordinator?
    let session: LoginSession
    
    init(root: UINavigationController,
         session: LoginSession) {
        self.root = root
        self.session = session
    }
    
    func start() {
        let configuration = LoginSessionConfiguration.oneLogin
        session.present(configuration: configuration)
    }
    
    func handleUniversalLink(_ url: URL) {
        print(url)
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        
        guard let authCode = components.queryItems?.first(where: { $0.name == "code" })?.value,
              let state = components.queryItems?.first(where: { $0.name == "state" })?.value else { return }
        
        print(authCode)
        print(state)
    }
}
