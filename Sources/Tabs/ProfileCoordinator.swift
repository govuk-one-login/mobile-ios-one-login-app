import Coordination
import GDSCommon
import LocalAuthentication
import Logging
import SecureStore
import UIKit

final class ProfileCoordinator: NSObject,
                                AnyCoordinator,
                                ChildCoordinator,
                                NavigationCoordinator {
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?

    private let userProvider: UserProvider
    private let analyticsService: AnalyticsService
    private let urlOpener: URLOpener
    private let walletAvailablityService: WalletFeatureAvailabilityService
    
    init(userProvider: UserProvider,
         analyticsService: AnalyticsService,
         urlOpener: URLOpener,
         walletAvailabilityService: WalletFeatureAvailabilityService) {
        self.userProvider = userProvider
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.walletAvailablityService = walletAvailabilityService
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_profileTitle").value,
                                       image: UIImage(systemName: "person.crop.circle"),
                                       tag: 2)
        let viewModel = ProfileTabViewModel(analyticsService: analyticsService,
                                            sectionModels: TabbedViewSectionFactory.profileSections(urlOpener: urlOpener,
                                                                                                    action: openSignOutPage))
        let profileViewController = TabbedViewController(viewModel: viewModel,
                                                         userProvider: userProvider,
                                                         headerView: SignInView())
        root.setViewControllers([profileViewController], animated: true)
    }
    
    func openSignOutPage() {
        let navController = UINavigationController()
        let walletAvailable = UserDefaults.standard.bool(forKey: "hasAccessedWalletBefore")
        let viewModel = showSignOutConfirmationScreen(walletAvailable: walletAvailable, navController: navController)
        let signOutViewController = GDSInstructionsViewController(viewModel: viewModel)
        navController.setViewControllers([signOutViewController], animated: false)
        root.present(navController, animated: true)
    }
    
    private func showSignOutConfirmationScreen(
        walletAvailable: Bool,
        navController: UINavigationController
    ) -> GDSInstructionsViewModel {
        return if (walletAvailable) {
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
}
