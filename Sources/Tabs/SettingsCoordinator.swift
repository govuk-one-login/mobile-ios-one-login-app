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
    
    private let analyticsCenter: AnalyticsCentral
    private let sessionManager: SessionManager & UserProvider
    private let networkClient: NetworkClient
    private let urlOpener: URLOpener
    
    init(analyticsCenter: AnalyticsCentral,
         sessionManager: SessionManager & UserProvider,
         networkClient: NetworkClient,
         urlOpener: URLOpener) {
        self.analyticsCenter = analyticsCenter
        self.sessionManager = sessionManager
        self.networkClient = networkClient
        self.urlOpener = urlOpener
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_settingsTitle").value,
                                       image: UIImage(systemName: "gearshape"),
                                       tag: 2)
        let viewModel = SettingsTabViewModel(analyticsService: analyticsCenter.analyticsService,
                                             userProvider: sessionManager,
                                             openSignOutPage: openSignOutPage,
                                             openDeveloperMenu: openDeveloperMenu)
        let settingsViewController = TabbedViewController(viewModel: viewModel,
                                                          userProvider: sessionManager,
                                                          analyticsPreference: analyticsCenter.analyticsPreferenceStore)
        root.setViewControllers([settingsViewController], animated: true)
    }
    
    func didBecomeSelected() {
        analyticsCenter.analyticsService.setAdditionalParameters(appTaxonomy: .settings)
        let event = IconEvent(textKey: "app_settingsTitle")
        analyticsCenter.analyticsService.logEvent(event)
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
        WalletSignOutPageViewModel(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
            navController.dismiss(animated: true) { [unowned self] in
                finish()
            }
        }
        : SignOutPageViewModel(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
            navController.dismiss(animated: true) { [unowned self] in
                finish()
            }
        }
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
