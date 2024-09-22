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
    private let analyticsService: AnalyticsService
    private let urlOpener: URLOpener
    private let walletAvailabilityService: WalletFeatureAvailabilityService
    private(set) var baseVc: TabbedViewController?
    
    init(analyticsService: AnalyticsService,
         urlOpener: URLOpener,
         walletAvailabilityService: WalletFeatureAvailabilityService = WalletAvailabilityService(),
         baseVc: TabbedViewController? = nil) {
        self.analyticsService = analyticsService
        self.urlOpener = urlOpener
        self.walletAvailabilityService = walletAvailabilityService
        self.baseVc = baseVc
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_profileTitle").value,
                                       image: UIImage(systemName: "person.crop.circle"),
                                       tag: 2)
        let viewModel = ProfileTabViewModel(analyticsService: analyticsService,
                                            sectionModels: TabbedViewSectionFactory.profileSections(urlOpener: urlOpener,
                                                                                                    action: openSignOutPage))
        let profileViewController = TabbedViewController(viewModel: viewModel,
                                                         headerView: SignInView())
        baseVc = profileViewController
        root.setViewControllers([profileViewController], animated: true)
    }
    
    func updateUser(_ user: User) {
        baseVc?.updateEmail(user.email)
    }
    
    func openSignOutPage() {
        let navController = UINavigationController()
        var viewModel: GDSInstructionsViewModel {
            walletAvailabilityService.hasAccessedPreviously ? SignOutConfirmationWalletViewModel(analyticsService: analyticsService) { [unowned self] in
               navController.dismiss(animated: true) { [unowned self] in
                   parentCoordinator?.childDidFinish(self)
               }
           } : SignOutConfirmationViewModel(analyticsService: analyticsService) { [unowned self] in
               navController.dismiss(animated: true) { [unowned self] in
                   parentCoordinator?.childDidFinish(self)
               }
           }
        }
        let signOutViewController = GDSInstructionsViewController(viewModel: viewModel)
        navController.setViewControllers([signOutViewController], animated: false)
        root.present(navController, animated: true)
    }
}
