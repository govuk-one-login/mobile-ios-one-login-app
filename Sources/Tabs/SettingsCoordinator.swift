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
    private let analyticsPreferenceStore: AnalyticsPreferenceStore
    private let sessionManager: SessionManager & UserProvider
    private let networkClient: NetworkClient
    private let urlOpener: URLOpener
    
    init(analyticsService: OneLoginAnalyticsService,
         analyticsPreferenceStore: AnalyticsPreferenceStore,
         sessionManager: SessionManager & UserProvider,
         networkClient: NetworkClient,
         urlOpener: URLOpener) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.system,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        self.analyticsPreferenceStore = analyticsPreferenceStore
        self.sessionManager = sessionManager
        self.networkClient = networkClient
        self.urlOpener = urlOpener
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_settingsTitle").value,
                                       image: UIImage(systemName: "gearshape"),
                                       tag: 2)
        let viewModel = SettingsTabViewModel(analyticsService: analyticsService,
                                             userProvider: sessionManager,
                                             urlOpener: urlOpener,
                                             openSignOutPage: openSignOutPage,
                                             openDeveloperMenu: openDeveloperMenu)
        let settingsViewController = SettingsViewController(viewModel: viewModel,
                                                            userProvider: sessionManager,
                                                            analyticsPreference: analyticsPreferenceStore)
        root.setViewControllers([settingsViewController], animated: true)
    }
    
    func didBecomeSelected() {
        let event = IconEvent(textKey: "app_settingsTitle")
        analyticsService.logEvent(event)
    }
    
    func openSignOutPage() {
        let navController = UINavigationController()
        let viewModel = showSignOutConfirmationScreen(navController: navController)
        let signOutViewController = GDSInstructionsViewController(viewModel: viewModel)
        navController.setViewControllers([signOutViewController], animated: false)
        root.present(navController, animated: true)
    }
    
    private func showSignOutConfirmationScreen(
        navController: UINavigationController
    ) -> GDSInstructionsViewModel {
        WalletAvailabilityService.hasAccessedBefore ?
        WalletSignOutPageViewModel(analyticsService: analyticsService) { [unowned self] in
            navController.dismiss(animated: true) { [unowned self] in
                showLoadingScreen()
                finish()
            }
        }
        : SignOutPageViewModel(analyticsService: analyticsService) { [unowned self] in
            navController.dismiss(animated: true) { [unowned self] in
                showLoadingScreen()
                finish()
            }
        }
    }
    
    private func showLoadingScreen() {
        let loginLoadingScreen = GDSLoadingViewController(
            viewModel: LoginLoadingViewModel(
                analyticsService: analyticsService
            )
        )
        root.pushViewController(loginLoadingScreen, animated: false)
    }
    
    func openDeveloperMenu() {
        let viewModel = DeveloperMenuViewModel()
        let service = HelloWorldService(client: networkClient, baseURL: AppEnvironment.stsHelloWorld)
        let devMenuViewController = DeveloperMenuViewController(viewModel: viewModel,
                                                                sessionManager: sessionManager,
                                                                helloWorldProvider: service)
        let navController = UINavigationController(rootViewController: devMenuViewController)
        root.present(navController, animated: true)
    }
}
