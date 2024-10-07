import Coordination
import GDSCommon
import LocalAuthentication
import Logging
import MobilePlatformServices
import Networking
import SecureStore
import UIKit

@MainActor
final class ProfileCoordinator: NSObject,
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
    
    init(analyticsService: AnalyticsService,
         sessionManager: SessionManager & UserProvider,
         networkClient: NetworkClient,
         urlOpener: URLOpener,
         walletAvailabilityService: WalletFeatureAvailabilityService) {
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
        self.networkClient = networkClient
        self.urlOpener = urlOpener
        self.walletAvailablityService = walletAvailabilityService
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_profileTitle").value,
                                       image: UIImage(systemName: "person.crop.circle"),
                                       tag: 2)
        let viewModel = ProfileTabViewModel(analyticsService: analyticsService,
                                            sectionModels: TabbedViewSectionFactory.profileSections(coordinator: self,
                                                                                                    urlOpener: urlOpener,
                                                                                                    action: openSignOutPage))
        let profileViewController = TabbedViewController(viewModel: viewModel,
                                                         userProvider: sessionManager,
                                                         headerView: SignInView())
        root.setViewControllers([profileViewController], animated: true)
    }
    
    func openSignOutPage() {
        let navController = UINavigationController()
        let walletAvailable = walletAvailablityService.hasAccessedBefore
        let viewModel = showSignOutConfirmationScreen(walletAvailable: walletAvailable, navController: navController)
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
