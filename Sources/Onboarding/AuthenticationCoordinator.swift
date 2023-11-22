import Authentication
import Coordination
import UIKit

final class AuthenticationCoordinator: NSObject,
                                       ChildCoordinator,
                                       NavigationCoordinator {
    let root: UINavigationController
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
        guard let mainCoordinator = parentCoordinator as? MainCoordinator else { return }
        Task {
            do {
                mainCoordinator.tokens = try await session.finalise(callback: url)
                finish()
            } catch {
                print(error)
            }
        }
    }
}
