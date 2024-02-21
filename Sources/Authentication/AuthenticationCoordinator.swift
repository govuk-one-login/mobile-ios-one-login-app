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
    let analyticsService: AnalyticsService
    let errorPresenter = ErrorPresenter.self
    var tokenHolder: TokenHolder
    
    init(root: UINavigationController,
         session: LoginSession,
         analyticsService: AnalyticsService,
         tokenHolder: TokenHolder) {
        self.root = root
        self.session = session
        self.analyticsService = analyticsService
        self.tokenHolder = tokenHolder
    }
    
    func start() {
        Task(priority: .userInitiated) {
            do {
                tokenHolder.tokenResponse = try await session.performLoginFlow(configuration: LoginSessionConfiguration.oneLogin)
                finish()
            } catch LoginError.network {
                let networkErrorScreen = errorPresenter
                    .createNetworkConnectionError(analyticsService: analyticsService) { [unowned self] in
                        root.popViewController(animated: true)
                    }
                root.pushViewController(networkErrorScreen, animated: true)
            } catch LoginError.non200, LoginError.invalidRequest, LoginError.clientError {
                let unableToLoginErrorScreen = errorPresenter
                    .createUnableToLoginError(analyticsService: analyticsService) { [unowned self] in
                        root.popViewController(animated: true)
                    }
                root.pushViewController(unableToLoginErrorScreen, animated: true)
            } catch LoginError.userCancelled {
                return
            } catch {
                let genericErrorScreen = errorPresenter
                    .createGenericError(analyticsService: analyticsService) { [unowned self] in
                        root.popViewController(animated: true)
                    }
                root.pushViewController(genericErrorScreen, animated: true)
            }
        }
    }
    
    func handleUniversalLink(_ url: URL) {
        do {
            try session.finalise(redirectURL: url)
        } catch {
            let genericErrorScreen = errorPresenter
                .createGenericError(analyticsService: analyticsService) { [unowned self] in
                    root.popViewController(animated: true)
                }
            root.pushViewController(genericErrorScreen, animated: true)
        }
    }
}
