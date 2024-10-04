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
    private let sessionManager: SessionManager

    private let networkClient: NetworkClient


    init(analyticsService: AnalyticsService,
         networkClient: NetworkClient,
         sessionManager: SessionManager) {
        self.analyticsService = analyticsService
        self.networkClient = networkClient
        self.sessionManager = sessionManager
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_homeTitle").value,
                                       image: UIImage(systemName: "house"),
                                       tag: 0)
        let viewModel = HomeTabViewModel(analyticsService: analyticsService,
                                         sectionModels: TabbedViewSectionFactory.homeSections())
        let hc = ContentViewController(viewModel: viewModel)
        root.setViewControllers([hc], animated: true)
    }
}
