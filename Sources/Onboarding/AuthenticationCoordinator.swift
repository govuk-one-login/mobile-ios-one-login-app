import Authentication
import Coordination
import Logging
import UIKit

final class AuthenticationCoordinator: NSObject,
                                       ChildCoordinator,
                                       NavigationCoordinator {
    let root: UINavigationController
    var parentCoordinator: ParentCoordinator?
    let session: LoginSession
    let errorPresenter: ErrorPresenter.Type
    let analyticsService: AnalyticsService
    
    init(root: UINavigationController,
         session: LoginSession,
         errorPresenter: ErrorPresenter.Type,
         analyticsService: AnalyticsService) {
        self.root = root
        self.session = session
        self.errorPresenter = errorPresenter
        self.analyticsService = analyticsService
    }
    
    func start() {
        let configuration = LoginSessionConfiguration.oneLogin
        session.present(configuration: configuration)
    }
    
    func handleUniversalLink(_ url: URL) {
        guard let mainCoordinator = parentCoordinator as? MainCoordinator else { return }
        Task(priority: .userInitiated) {
            do {
                mainCoordinator.tokens = try await session.finalise(redirectURL: url)
            } catch {
                let genericErrorScreen = errorPresenter.createGenericError(analyticsService: analyticsService, action: { })
                root.pushViewController(genericErrorScreen, animated: true)
            }
            finish()
        }
    }
}
