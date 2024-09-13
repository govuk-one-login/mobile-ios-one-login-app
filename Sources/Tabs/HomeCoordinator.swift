import Authentication
import Combine
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
    private(set) var baseVc: TabbedViewController?

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
                                         sectionModels: TabbedViewSectionFactory.homeSections(coordinator: self))
        let hc = TabbedViewController(viewModel: viewModel,
                                      userProvider: sessionManager,
                                      headerView: SignInView())
        baseVc = hc
        root.setViewControllers([hc], animated: true)
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
