import Authentication
import Coordination
import GDSAnalytics
import GDSCommon
import Logging
import UIKit

final class AuthenticationCoordinator: NSObject,
                                       ChildCoordinator,
                                       NavigationCoordinator {
    let root: UINavigationController
    weak var parentCoordinator: ParentCoordinator?
    let analyticsService: AnalyticsService
    let session: LoginSession
    let errorPresenter = ErrorPresenter.self
    var tokenHolder: TokenHolder
    private var tokenVerifier: TokenVerifier
    var authError: Error?
    
    init(root: UINavigationController,
         analyticsService: AnalyticsService,
         session: LoginSession,
         tokenHolder: TokenHolder,
         tokenVerifier: TokenVerifier = JWTVerifier()) {
        self.root = root
        self.analyticsService = analyticsService
        self.session = session
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
                        returnFromErrorScreen()
                    }
                root.pushViewController(networkErrorScreen, animated: true)
                authError = error
            } catch let error as LoginError where error == .userCancelled {
                authError = error
                logUserCancelEvent()
                finish()
            } catch let error as LoginError where error == .non200,
                    let error as LoginError where error == .invalidRequest,
                    let error as LoginError where error == .clientError {
                showUnableToLoginErrorScreen(error)
            } catch let error as JWTVerifierError {
                showUnableToLoginErrorScreen(error)
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
            let loginLoadingScreen = GDSLoadingViewController(viewModel: LoginLoadingViewModel(analyticsService: analyticsService))
            root.pushViewController(loginLoadingScreen, animated: false)
            try session.finalise(redirectURL: url)
        } catch {
            showGenericErrorScreen(error)
        }
    }
}

extension AuthenticationCoordinator {
    private func showUnableToLoginErrorScreen(_ error: Error) {
        let unableToLoginErrorScreen = errorPresenter
            .createUnableToLoginError(errorDescription: error.localizedDescription,
                                      analyticsService: analyticsService) { [unowned self] in
                returnFromErrorScreen()
            }
        root.pushViewController(unableToLoginErrorScreen, animated: true)
        authError = error
    }
    
    private func showGenericErrorScreen(_ error: Error) {
        let genericErrorScreen = errorPresenter
            .createGenericError(errorDescription: error.localizedDescription,
                                analyticsService: analyticsService) { [unowned self] in
                returnFromErrorScreen()
            }
        root.pushViewController(genericErrorScreen, animated: true)
        authError = error
    }
    
    private func returnFromErrorScreen() {
        root.viewControllers.removeLast()
        root.popViewController(animated: true)
        finish()
    }
    
    private func logUserCancelEvent() {
        let userCancelEvent = ButtonEvent(textKey: "back")
        analyticsService.logEvent(userCancelEvent)
    }
}
