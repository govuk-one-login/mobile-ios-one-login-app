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
    private let walletAvailablityService: WalletFeatureAvailabilityService
    private let analyticsPreference: AnalyticsPreferenceStore
    
    init(analyticsService: AnalyticsService,
         sessionManager: SessionManager & UserProvider,
         networkClient: NetworkClient,
         urlOpener: URLOpener,
         walletAvailabilityService: WalletFeatureAvailabilityService,
         analyticsPreference: AnalyticsPreferenceStore) {
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
        self.networkClient = networkClient
        self.urlOpener = urlOpener
        self.walletAvailablityService = walletAvailabilityService
        self.analyticsPreference = analyticsPreference
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_settingsTitle").value,
                                       image: UIImage(systemName: "person.crop.circle"),
                                       tag: 2)
        let viewModel = SettingsTabViewModel(analyticsService: analyticsService,
                                            sectionModels: TabbedViewSectionFactory.settingsSections(coordinator: self,
                                                                                                    urlOpener: urlOpener,
                                                                                                    action: openSignOutPage))
        let settingsViewController = TabbedViewController(viewModel: viewModel,
                                                         userProvider: sessionManager,
                                                         headerView: SignInView(),
                                                         analyticsPreference: analyticsPreference)
        root.setViewControllers([settingsViewController], animated: true)
    }
    
    func openSignOutPage() {
        let navController = UINavigationController()
        let viewModel = showSignOutConfirmationScreen(walletAvailable: walletAvailablityService.hasAccessedBefore,
                                                      navController: navController)
        let signOutViewController = GDSInstructionsViewController(viewModel: viewModel)
        navController.setViewControllers([signOutViewController], animated: false)
        root.present(navController, animated: true)
    }
    
    private func showSignOutConfirmationScreen(
        walletAvailable: Bool,
        navController: UINavigationController
    ) -> GDSInstructionsViewModel {
        return if walletAvailable {
            WalletSignOutPageViewModel(analyticsService: analyticsService) { [unowned self] in
                navController.dismiss(animated: true) { [unowned self] in
                    finish()
                }
            }
        } else {
            SignOutPageViewModel(analyticsService: analyticsService) { [unowned self] in
                navController.dismiss(animated: true) { [unowned self] in
                    finish()
                }
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
