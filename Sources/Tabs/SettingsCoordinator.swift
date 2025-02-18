import Coordination
import GDSCommon
import LocalAuthentication
import Logging
import MobilePlatformServices
import Networking
import SecureStore
import UIKit

@MainActor
final class SettingsCoordinator: NSObject,
                                AnyCoordinator,
                                ChildCoordinator,
                                NavigationCoordinator {
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?

    private let analyticsService: AnalyticsService
    private let sessionManager: SessionManager & UserProvider
    private let networkClient: NetworkClient
    private let urlOpener: URLOpener
    private let analyticsPreference: AnalyticsPreferenceStore
        
    init(analyticsService: AnalyticsService,
         sessionManager: SessionManager & UserProvider,
         networkClient: NetworkClient,
         urlOpener: URLOpener,
         analyticsPreference: AnalyticsPreferenceStore) {
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
        self.networkClient = networkClient
        self.urlOpener = urlOpener
        self.analyticsPreference = analyticsPreference
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_settingsTitle").value,
                                       image: UIImage(systemName: "gearshape"),
                                       tag: 2)
        let viewModel = SettingsTabViewModel(analyticsService: analyticsService,
                                             sectionModels: TabbedViewSectionFactory.settingsSections(coordinator: self,
                                                                                                      urlOpener: urlOpener,
                                                                                                      userEmail:
                                                                                                        sessionManager.user.value?.email ?? "",
                                                                                                    action: openSignOutPage))
        let settingsViewController = TabbedViewController(viewModel: viewModel,
                                                          userProvider: sessionManager,
                                                          analyticsPreference: analyticsPreference)
        root.setViewControllers([settingsViewController], animated: true)
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
                finish()
            }
        }
        : SignOutPageViewModel(analyticsService: analyticsService) { [unowned self] in
            navController.dismiss(animated: true) { [unowned self] in
                finish()
            }
        }
    }
    
    func showDeveloperMenu() {
        let viewModel = DeveloperMenuViewModel()
        let service = HelloWorldService(client: networkClient, baseURL: AppEnvironment.stsHelloWorld)
        let devMenuViewController = DeveloperMenuViewController(viewModel: viewModel,
                                                                sessionManager: sessionManager,
                                                                helloWorldProvider: service)
        let navController = UINavigationController(rootViewController: devMenuViewController)
        root.present(navController, animated: true)
    }
}
