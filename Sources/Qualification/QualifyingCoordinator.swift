import Coordination
import GDSCommon
import Logging
import Networking
import SecureStore
import UIKit

/// A type that is responsible for coordinating the user's eligibility to access the main functionality of the app.
///
/// Performs orchestration based on the state of the app to send the user to either:
/// - Login Coordinator: requiring the user to authenticate to enter the app.
/// - Main Coordinator: allowing the user to access the main app functionality (i.e. Wallet)
///
@MainActor
final class QualifyingCoordinator: NSObject,
                                   ParentCoordinator,
                                   AppQualifyingServiceDelegate {
    private var unlockWindow: UIWindow?
    private let appWindow: UIWindow
    var childCoordinators = [ChildCoordinator]()
    var deeplink: URL?

    private let analyticsCenter: AnalyticsCentral
    private let appQualifyingService: QualifyingService
    private let sessionManager: SessionManager
    private let networkClient: NetworkClient
    private let walletAvailabilityService: WalletFeatureAvailabilityService

    private var loginCoordinator: LoginCoordinator? {
        childCoordinators.firstInstanceOf(LoginCoordinator.self)
    }

    private var tabManagerCoordinator: TabManagerCoordinator? {
        childCoordinators.firstInstanceOf(TabManagerCoordinator.self)
    }

    private lazy var unlockViewController = {
        let viewModel = UnlockScreenViewModel(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
            Task {
                await appQualifyingService.evaluateUser()
            }
        }
        return UnlockScreenViewController(viewModel: viewModel)
    }()

    init(appWindow: UIWindow,
         analyticsCenter: AnalyticsCentral,
         appQualifyingService: QualifyingService,
         sessionManager: SessionManager,
         networkClient: NetworkClient,
         walletAvailabilityService: WalletFeatureAvailabilityService) {
        self.appWindow = appWindow
        self.appQualifyingService = appQualifyingService
        self.analyticsCenter = analyticsCenter
        self.sessionManager = sessionManager
        self.networkClient = networkClient
        self.walletAvailabilityService = walletAvailabilityService
        super.init()
        self.appQualifyingService.delegate = self
    }
    
    func start() {
        displayUnlockWindow()
    }
    
    func didChangeAppInfoState(state appInfoState: AppInformationState) {
        switch appInfoState {
        case .notChecked:
            displayUnlockWindow()
        case .offline:
            // TODO: DCMAW-9866 | display error screen for app offline and no cached data
            return
        case .error:
            // TODO: DCMAW-9866 | display generic error screen?
            return
        case .unavailable:
            let updateAppScreen = GDSInformationViewController(
                viewModel: AppUnavailableViewModel(analyticsService: analyticsCenter.analyticsService)
            )
            displayViewController(updateAppScreen)
        case .outdated:
            let updateAppScreen = GDSInformationViewController(
                viewModel: UpdateAppViewModel(analyticsService: analyticsCenter.analyticsService)
            )
            displayViewController(updateAppScreen)
        case .qualified:
            // End loading state and enable button
            unlockViewController.isLoading = false
        }
    }
    
    func didChangeUserState(state userState: AppLocalAuthState) {
        switch userState {
        case .loggedIn:
            launchTabManagerCoordinator()
        case .notLoggedIn, .expired:
            launchLoginCoordinator(userState: userState)
        case .failed(let error):
            let viewModel = UnableToLoginErrorViewModel(analyticsService: analyticsCenter.analyticsService,
                                                        errorDescription: error.localizedDescription) { [unowned self] in
                analyticsCenter.analyticsService.logCrash(error)
                fatalError("We were unable to resume the session, there's not much we can do to help the user")
            }
            let unableToLoginErrorScreen = GDSErrorViewController(viewModel: viewModel)
            displayViewController(unableToLoginErrorScreen)
        }
    }
    
    func launchLoginCoordinator(userState: AppLocalAuthState) {
        if let loginCoordinator {
            displayViewController(loginCoordinator.root)
        } else {
            let loginCoordinator = LoginCoordinator(
                appWindow: appWindow,
                root: UINavigationController(),
                analyticsCenter: analyticsCenter,
                sessionManager: sessionManager,
                isExpiredUser: userState == .expired
            )
            displayChildCoordinator(loginCoordinator)
        }
    }
    
    func launchTabManagerCoordinator() {
        if let tabManagerCoordinator {
            displayViewController(tabManagerCoordinator.root)
        } else {
            let tabManagerCoordinator = TabManagerCoordinator(
                appWindow: appWindow,
                root: UITabBarController(),
                analyticsCenter: analyticsCenter,
                networkClient: networkClient,
                sessionManager: sessionManager,
                walletAvailabilityService: walletAvailabilityService)
            displayChildCoordinator(tabManagerCoordinator)
        }
        if let deeplink {
            tabManagerCoordinator?.handleUniversalLink(deeplink)
            self.deeplink = nil
        }
    }

    func handleUniversalLink(_ url: URL) {
        switch UniversalLinkQualifier.qualifyOneLoginUniversalLink(url) {
        case .login:
            loginCoordinator?.handleUniversalLink(url)
        case .wallet:
            guard appWindow.rootViewController is UITabBarController else {
                deeplink = url
                return
            }
            tabManagerCoordinator?.handleUniversalLink(url)
        case .unknown:
            return
        }
    }

    private func displayChildCoordinator(_ coordinator: any ChildCoordinator & AnyCoordinator) {
        // display in window:
        displayViewController(coordinator.root)

        // TODO: DCMAW-9866 | call `openChild` within `ParentCoordinator.swift`
        childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
        coordinator.start()
    }

    private func displayViewController(_ viewController: UIViewController) {
        appWindow.rootViewController = viewController
        appWindow.makeKeyAndVisible()
        unlockWindow?.isHidden = true
        unlockWindow = nil
    }
    
    func displayUnlockWindow() {
        if let unlockWindow { return }
        guard let appWindowScene = appWindow.windowScene else { return }
        unlockWindow = UIWindow(windowScene: appWindowScene)
        unlockWindow?.rootViewController = unlockViewController
        unlockWindow?.windowLevel = .alert
        unlockWindow?.makeKeyAndVisible()
    }
}
