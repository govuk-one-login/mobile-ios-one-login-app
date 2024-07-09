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
    var analyticsService: AnalyticsService
    var userStore: UserStorable
    private let urlOpener: URLOpener
    private(set) var baseVc: TabbedViewController?
    
    init(analyticsService: AnalyticsService,
         userStore: UserStorable,
         urlOpener: URLOpener,
         baseVc: TabbedViewController? = nil) {
        self.analyticsService = analyticsService
        self.userStore = userStore
        self.urlOpener = urlOpener
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
    
    func updateToken() {
        baseVc?.updateToken(TokenHolder.shared)
    }
    
    func openSignOutPage() {
        let navController = UINavigationController()
        let viewModel = SignOutPageViewModel(analyticsService: analyticsService) { [unowned self] in
            navController.dismiss(animated: true) { [unowned self] in
                parentCoordinator?.childDidFinish(self)
            }
        }
        let signOutViewController = GDSInstructionsViewController(viewModel: viewModel)
        navController.setViewControllers([signOutViewController], animated: false)
        root.present(navController, animated: true)
    }
}
