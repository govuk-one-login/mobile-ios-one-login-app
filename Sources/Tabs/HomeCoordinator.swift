import Authentication
import Coordination
import GDSCommon
import LocalAuthentication
import Logging
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

    private lazy var networkClient: NetworkClient = {
        NetworkClient(authenticationProvider: sessionManager.tokenProvider)
    }()

    private(set) var baseVc: TabbedViewController?
    
    init(analyticsService: AnalyticsService,
         sessionManager: SessionManager) {
        self.analyticsService = analyticsService
        self.sessionManager = sessionManager
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_homeTitle").value,
                                       image: UIImage(systemName: "house"),
                                       tag: 0)
        let viewModel = HomeTabViewModel(analyticsService: analyticsService,
                                         sectionModels: TabbedViewSectionFactory.homeSections(coordinator: self))
        let hc = TabbedViewController(viewModel: viewModel,
                                      headerView: SignInView())
        baseVc = hc
        root.setViewControllers([hc], animated: true)
    }
    
    func updateUser(_ user: User) {
        baseVc?.updateEmail(user.email)
        baseVc?.isLoggedIn(true)
        baseVc?.screenAnalytics()
    }
    
    func showDeveloperMenu() {
        let viewModel = DeveloperMenuViewModel()
        let devMenuViewController = DeveloperMenuViewController(parentCoordinator: self,
                                                                viewModel: viewModel,
                                                                sessionManager: sessionManager,
                                                                networkClient: networkClient)
        let navController = UINavigationController()
        navController.setViewControllers([devMenuViewController], animated: false)
        root.present(navController, animated: true)
    }
    
    func accessTokenInvalidAction() {
        root.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name(.startReauth), object: nil)
        }
    }
}
