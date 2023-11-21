import Authentication
import Coordination
import UIKit

final class AuthenticationCoordinator: NSObject,
                                       ChildCoordinator,
                                       NavigationCoordinator {
    let window: UIWindow
    let root: UINavigationController
    var parentCoordinator: ParentCoordinator?
    let session: LoginSession
    
    init(window: UIWindow,
         root: UINavigationController) {
        self.window = window
        self.root = root
        self.session = AppAuthSession(window: window)
    }
    
    func start() {
        let configuration = LoginSessionConfiguration.oneLogin
        session.present(configuration: configuration)
    }
    
    func handleUniversalLink(_ url: URL) {
        guard let mainCoordinator = parentCoordinator as? MainCoordinator else { return }
        Task {
            do {
                mainCoordinator.tokenHolder = try await session.finalise(callback: url,
                                                                         endpoint: AppEnvironment.oneLoginToken)
                dump(mainCoordinator.tokenHolder)
                finish()
            } catch {
                print(error)
            }
        }
    }
}
