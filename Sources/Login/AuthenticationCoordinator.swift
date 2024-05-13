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
                if AppEnvironment.callingSTSEnabled {
                    // TODO: DCMAW-8570 This should be considiered non-optional once tokenID work is completed on BE
                    if let idToken = tokenHolder.tokenResponse?.idToken {
                        tokenHolder.idToken = try await verifyIDToken(idToken)
                    }
                }
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
                showLoginErrorScreen(error)
            } catch let error as LoginError where error == .userCancelled {
                loginError = error
                finish()
            } catch let error as JWTVerifierError {
                loginError = error
                showLoginErrorScreen(error)
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

extension AuthenticationCoordinator {
    private func verifyIDToken(_ token: String) async throws -> IdTokenInfo? {
        let verifier = JWTVerifier(token: token)
        return try await verifier.verifyCredential()
    }
    
    private func showLoginErrorScreen(_ error: Error) {
        let unableToLoginErrorScreen = errorPresenter
            .createUnableToLoginError(errorDescription: error.localizedDescription,
                                      analyticsService: analyticsService) { [unowned self] in
                root.popViewController(animated: true)
                finish()
            }
        root.pushViewController(unableToLoginErrorScreen, animated: true)
        loginError = error
    }
}
