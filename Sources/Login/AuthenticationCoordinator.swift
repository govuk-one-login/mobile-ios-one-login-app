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
    var loginError: Error?
    
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
                tokenHolder.accessToken = tokenHolder.tokenResponse?.accessToken
                finish()
            } catch let error as LoginError where error == .network {
                let networkErrorScreen = errorPresenter
                    .createNetworkConnectionError(analyticsService: analyticsService) { [unowned self] in
                        root.popViewController(animated: true)
                        finish()
                    }
                root.pushViewController(networkErrorScreen, animated: true)
                loginError = error
            } catch let error as LoginError where error == .non200,
                    let error as LoginError where error == .invalidRequest,
                    let error as LoginError where error == .clientError {
                let unableToLoginErrorScreen = errorPresenter
                    .createUnableToLoginError(errorDescription: error.localizedDescription,
                                              analyticsService: analyticsService) { [unowned self] in
                        root.popViewController(animated: true)
                        finish()
                    }
                root.pushViewController(unableToLoginErrorScreen, animated: true)
                loginError = error
            } catch let error as LoginError where error == .userCancelled {
                loginError = error
                finish()
            } catch {
                let genericErrorScreen = errorPresenter
                    .createGenericError(errorDescription: error.localizedDescription,
                                        analyticsService: analyticsService) { [unowned self] in
                        root.popViewController(animated: true)
                        finish()
                    }
                root.pushViewController(genericErrorScreen, animated: true)
                loginError = error
            }
        }
    }
    
    func handleUniversalLink(_ url: URL) {
        do {
            try session.finalise(redirectURL: url)
        } catch {
            let genericErrorScreen = errorPresenter
                .createGenericError(errorDescription: error.localizedDescription,
                                    analyticsService: analyticsService) { [unowned self] in
                    root.popViewController(animated: true)
                    finish()
                }
            root.pushViewController(genericErrorScreen, animated: true)
            loginError = error
        }
    }
}
