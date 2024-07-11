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
    let userStore: UserStorable
    private let tokenVerifier: TokenVerifier
    var authError: Error?
    
    init(root: UINavigationController,
         analyticsService: AnalyticsService,
         userStore: UserStorable,
         session: LoginSession,
         tokenVerifier: TokenVerifier = JWTVerifier()) {
        self.root = root
        self.analyticsService = analyticsService
        self.userStore = userStore
        self.session = session
        self.tokenVerifier = tokenVerifier
    }
    
    func start() {
        Task(priority: .userInitiated) {
            do {
                TokenHolder.shared.tokenResponse = try await session.performLoginFlow(configuration: userStore.constructLoginSessionConfiguration())
                // TODO: DCMAW-8570 This should be considered non-optional once tokenID work is completed on BE
                if AppEnvironment.callingSTSEnabled,
                   let idToken = TokenHolder.shared.tokenResponse?.idToken {
                    TokenHolder.shared.idTokenPayload = try await tokenVerifier.verifyToken(idToken)
                    try userStore.saveItem(TokenHolder.shared.idTokenPayload?.persistentId,
                                           itemName: .persistentSessionID,
                                           storage: .open)
                }
                finish()
            } catch let error as LoginError where error == .network {
                let networkErrorScreen = ErrorPresenter
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
        let unableToLoginErrorScreen = ErrorPresenter
            .createUnableToLoginError(errorDescription: error.localizedDescription,
                                      analyticsService: analyticsService) { [unowned self] in
                returnFromErrorScreen()
            }
        root.pushViewController(unableToLoginErrorScreen, animated: true)
        authError = error
    }
    
    private func showGenericErrorScreen(_ error: Error) {
        let genericErrorScreen = ErrorPresenter
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
