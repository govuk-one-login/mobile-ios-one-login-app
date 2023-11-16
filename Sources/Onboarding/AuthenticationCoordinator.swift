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
        // This method will contain the call to throwing session.finalise(url:) and errors will be handled with qualifying the URL
    }
}
