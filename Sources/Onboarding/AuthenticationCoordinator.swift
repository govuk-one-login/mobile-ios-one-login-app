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
        guard let mainCoordinator = parentCoordinator as? MainCoordinator else { return }
        Task(priority: .userInitiated) {
            do {
                mainCoordinator.tokens = try await session.performLoginFlow(configuration: LoginSessionConfiguration.oneLogin)
                finish()
            } catch LoginError.network {
                let networkErrorScreen = errorPresenter.createNetworkConnectionError(analyticsService: analyticsService) {
                    self.root.popViewController(animated: true)
                }
                root.pushViewController(networkErrorScreen, animated: true)
            } catch LoginError.non200, LoginError.invalidRequest, LoginError.clientError {
                let unableToLoginErrorScreen = errorPresenter.createUnableToLoginError(analyticsService: analyticsService) {
                    self.root.popViewController(animated: true)
                }
                root.pushViewController(unableToLoginErrorScreen, animated: true)
            } catch LoginError.userCancelled {
                return
            } catch {
                let genericErrorScreen = errorPresenter.createGenericError(analyticsService: analyticsService) {
                    self.root.popViewController(animated: true)
                }
                root.pushViewController(genericErrorScreen, animated: true)
            }
        }
    }
    
    func handleUniversalLink(_ url: URL) {
        do {
            try session.finalise(redirectURL: url)
        } catch {
            let genericErrorScreen = errorPresenter.createGenericError(analyticsService: analyticsService) {
                self.root.popViewController(animated: true)
            }
            root.pushViewController(genericErrorScreen, animated: true)
        }
    }
}
