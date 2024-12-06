import Authentication
import Coordination
import GDSAnalytics
import GDSCommon
import Logging
import UIKit

final class AuthenticationCoordinator: NSObject,
                                       ChildCoordinator,
                                       NavigationCoordinator {
    private let window: UIWindow
    let root: UINavigationController
    weak var parentCoordinator: ParentCoordinator?
    private let analyticsService: AnalyticsService
    private let session: LoginSession
    private let sessionManager: SessionManager
    var authError: Error?
    
    init(window: UIWindow,
         root: UINavigationController,
         analyticsService: AnalyticsService,
         sessionManager: SessionManager,
         session: LoginSession) {
        self.window = window
        self.root = root
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
        self.session = session
    }
    
    func start() {
        Task(priority: .userInitiated) {
            do {
                try await sessionManager.startSession(using: session,
                                                      configurationProvider: LoginSessionConfiguration.self)
                finish()
            } catch PersistentSessionError.sessionMismatch {
                let viewModel = DataDeletedWarningViewModel { [unowned self] in
                    start()
                }
                let vc = GDSErrorViewController(viewModel: viewModel)
                root.pushViewController(vc, animated: true)
                authError = PersistentSessionError.sessionMismatch
            } catch PersistentSessionError.cannotDeleteData(let error) {
                let viewModel = UnableToLoginErrorViewModel(analyticsService: analyticsService,
                                                            errorDescription: error.localizedDescription) { [unowned self] in
                    analyticsService.logCrash(error)
                    fatalError("There's nothing we can do to help the user if we cannot delete their data")
                }
                let vc = GDSErrorViewController(viewModel: viewModel)
                root.pushViewController(vc, animated: true)
                authError = PersistentSessionError.cannotDeleteData(error)
            } catch let error as LoginError where error == .network {
                let viewModel = NetworkConnectionErrorViewModel(analyticsService: analyticsService) { [unowned self] in
                    returnFromErrorScreen()
                }
                let networkErrorScreen = GDSErrorViewController(viewModel: viewModel)
                root.pushViewController(networkErrorScreen, animated: true)
                authError = error
            } catch let error as LoginError where error == .userCancelled {
                authError = error
                logUserCancelEvent()
                finish()
            } catch let error as LoginError where error == .non200,
                    let error as LoginError where error == .invalidRequest,
                    let error as LoginError where error == .clientError,
                    let error as LoginError where error == .serverError {
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
            window.rootViewController?.presentedViewController?.dismiss(animated: true)
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
        let viewModel = UnableToLoginErrorViewModel(analyticsService: analyticsService,
                                                    errorDescription: error.localizedDescription) { [unowned self] in
            returnFromErrorScreen()
        }
        let unableToLoginErrorScreen = GDSErrorViewController(viewModel: viewModel)
        root.pushViewController(unableToLoginErrorScreen, animated: true)
        authError = error
    }
    
    private func showGenericErrorScreen(_ error: Error) {
        let viewModel = GenericErrorViewModel(analyticsService: analyticsService,
                                              errorDescription: error.localizedDescription) { [unowned self] in
            returnFromErrorScreen()
        }
        let genericErrorScreen = GDSErrorViewController(viewModel: viewModel)
        root.pushViewController(genericErrorScreen, animated: true)
        authError = error
    }
    
    private func returnFromErrorScreen() {
        finish()
    }
    
    private func logUserCancelEvent() {
        let userCancelEvent = ButtonEvent(textKey: "back")
        analyticsService.logEvent(userCancelEvent)
    }
}
