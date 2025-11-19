import Coordination
import GDSAnalytics
import GDSCommon
import Logging
import MobilePlatformServices
import Networking
import UIKit

@MainActor
final class SettingsCoordinator: NSObject,
                                 AnyCoordinator,
                                 ChildCoordinator,
                                 NavigationCoordinator,
                                 TabItemCoordinator {
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?
    
    private let analyticsService: OneLoginAnalyticsService
    private let sessionManager: SessionManager & UserProvider
    private let networkService: OneLoginNetworkService
    private let urlOpener: URLOpener
    
    init(
        analyticsService: OneLoginAnalyticsService,
        sessionManager: SessionManager & UserProvider,
        networkService: OneLoginNetworkService,
        urlOpener: URLOpener
    ) {
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
        self.networkService = networkService
        self.urlOpener = urlOpener
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(
            title: GDSLocalisedString(stringLiteral: "app_settingsTitle").value,
            image: UIImage(systemName: "gearshape"),
            tag: 2
        )
        let viewModel = SettingsTabViewModel(
            analyticsService: analyticsService,
            userProvider: sessionManager,
            urlOpener: urlOpener,
            openSignOutPage: openSignOutPage,
            openDeveloperMenu: openDeveloperMenu
        )
        let settingsViewController = SettingsViewController(
            viewModel: viewModel,
            userProvider: sessionManager,
            analyticsPreference: analyticsService.analyticsPreferenceStore
        )
        root.setViewControllers([settingsViewController], animated: true)
    }
    
    func didBecomeSelected() {
        let event = IconEvent(textKey: "app_settingsTitle")
        analyticsService.logEvent(event)
        let tabCoordinator = (parentCoordinator as? TabManagerCoordinator)
        tabCoordinator?.updateSelectedTabIndex()
    }
    
    func openSignOutPage() {
        let navController = UINavigationController()
        let viewModel = SignOutPageViewModel(analyticsService: analyticsService) { [unowned self] in
            root.dismiss(animated: true) { [unowned self] in
                showLoadingScreen()
                logOut()
            }
        }
        let signOutViewController = GDSInstructionsViewController(viewModel: viewModel)
        navController.setViewControllers([signOutViewController], animated: false)
        root.present(navController, animated: true)
    }
    
    private func showLoadingScreen() {
        let loginLoadingScreen = GDSLoadingViewController(
            viewModel: LoginLoadingViewModel(
                analyticsService: analyticsService
            )
        )
        root.pushViewController(loginLoadingScreen, animated: false)
    }
    
    private func logOut() {
        Task {
            do {
                try await sessionManager.clearAllSessionData(presentSystemLogOut: false)
                finish()
            } catch {
                let viewModel = SignOutErrorViewModel(
                    analyticsService: analyticsService,
                    error: error
                ) { [unowned self] in
                    root.popToRootViewController(animated: true)
                    root.dismiss(animated: true)
                }
                let signOutErrorScreen = GDSErrorScreen(viewModel: viewModel)
                root.present(signOutErrorScreen, animated: true)
            }
        }
    }
    
    func openDeveloperMenu() {
        let viewModel = DeveloperMenuViewModel()
        let service = HelloWorldService(
            networkService: networkService,
            baseURL: AppEnvironment.stsHelloWorld
        )
        let devMenuViewController = DeveloperMenuViewController(
            viewModel: viewModel,
            sessionManager: sessionManager,
            helloWorldProvider: service
        )
        let navController = UINavigationController(rootViewController: devMenuViewController)
        root.present(navController, animated: true)
    }
}
