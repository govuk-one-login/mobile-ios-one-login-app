import Authentication
import Coordination
import GDSCommon
import Logging
import UIKit

final class AuthenticationCoordinator: NSObject,
                                       ChildCoordinator,
                                       NavigationCoordinator {
    let root: UINavigationController
    weak var parentCoordinator: ParentCoordinator?
    let session: LoginSession
    let analyticsService: AnalyticsService
    let errorPresenter = ErrorPresenter.self
    var tokenHolder: TokenHolder
    var loginError: Error?
    private var tokenVerifier: TokenVerifier
    
    init(root: UINavigationController,
         session: LoginSession,
         analyticsService: AnalyticsService,
         tokenHolder: TokenHolder,
         tokenVerifier: TokenVerifier = JWTVerifier()) {
        self.root = root
        self.session = session
        self.analyticsService = analyticsService
        self.tokenHolder = tokenHolder
        self.tokenVerifier = tokenVerifier
    }
    
    func start() {
        Task(priority: .userInitiated) {
            do {
                tokenHolder.tokenResponse = try await session.performLoginFlow(configuration: LoginSessionConfiguration.oneLogin)
                // TODO: DCMAW-8570 This should be considered non-optional once tokenID work is completed on BE
                if AppEnvironment.callingSTSEnabled,
                    let idToken = tokenHolder.tokenResponse?.idToken {
                    tokenHolder.idTokenPayload = try await tokenVerifier.verifyToken(idToken)
                }
                finish()
            } catch let error as LoginError where error == .network {
                let networkErrorScreen = errorPresenter
                    .createNetworkConnectionError(analyticsService: analyticsService) { [unowned self] in
                        root.popViewController(animated: true)
                        finish()
                    }
                root.pushViewController(networkErrorScreen, animated: true)
                removeLoginLoadingScreen()
                loginError = error
            } catch let error as LoginError where error == .non200,
                    let error as LoginError where error == .invalidRequest,
                    let error as LoginError where error == .clientError {
                showLoginErrorScreen(error)
            } catch let error as LoginError where error == .userCancelled {
                loginError = error
                finish()
            } catch let error as JWTVerifierError {
                showLoginErrorScreen(error)
            } catch {
                showGenericErrorScreen(error)
            }
        }
    }
    
    func handleUniversalLink(_ url: URL) {
        do {
            if let loginCoordinator = parentCoordinator as? LoginCoordinator {
                loginCoordinator.introViewController?.enableIntroButton()
            }
            let loginLoadingScreen = GDSLoadingViewController(viewModel: LoginLoadingViewModel())
            root.pushViewController(loginLoadingScreen, animated: false)
            try session.finalise(redirectURL: url)
        } catch {
            showGenericErrorScreen(error)
        }
    }
}

extension AuthenticationCoordinator {
    private func showLoginErrorScreen(_ error: Error) {
        let unableToLoginErrorScreen = errorPresenter
            .createUnableToLoginError(errorDescription: error.localizedDescription,
                                      analyticsService: analyticsService) { [unowned self] in
                root.popViewController(animated: true)
                finish()
            }
        root.pushViewController(unableToLoginErrorScreen, animated: true)
        removeLoginLoadingScreen()
        loginError = error
    }
    
    private func showGenericErrorScreen(_ error: Error) {
        let genericErrorScreen = errorPresenter
            .createGenericError(errorDescription: error.localizedDescription,
                                analyticsService: analyticsService) { [unowned self] in
                root.popViewController(animated: true)
                finish()
            }
        root.pushViewController(genericErrorScreen, animated: true)
        removeLoginLoadingScreen()
        loginError = error
    }
    
    private func removeLoginLoadingScreen() {
        root.viewControllers.remove(at: root.viewControllers.count - 1)
    }
}
