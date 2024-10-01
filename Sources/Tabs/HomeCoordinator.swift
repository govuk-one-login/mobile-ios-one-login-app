import Authentication
import Coordination
import GDSCommon
import LocalAuthentication
import Logging
import MobilePlatformServices
import Networking
import UIKit

final class HomeCoordinator: NSObject,
                             AnyCoordinator,
                             ChildCoordinator,
                             NavigationCoordinator {
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?
    var childCoordinators = [ChildCoordinator]()
    private let analyticsService: AnalyticsService
    private(set) var baseVc: TabbedViewController?
    private(set) var baseVc2: ContentViewController?

    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_homeTitle").value,
                                       image: UIImage(systemName: "house"),
                                       tag: 0)
        let viewModel = HomeTabViewModel(analyticsService: analyticsService,
                                         sectionModels: TabbedViewSectionFactory.homeSections())
        let hc = ContentViewController(viewModel: viewModel)
        baseVc2 = hc
        root.setViewControllers([hc], animated: true)
    }
    
    func updateUser(_ user: User) {
        baseVc?.updateEmail(user.email)
        baseVc?.isLoggedIn(true)
        baseVc?.screenAnalytics()
    }
}
