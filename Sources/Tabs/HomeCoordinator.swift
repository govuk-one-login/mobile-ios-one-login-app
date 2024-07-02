import Authentication
import Coordination
import GDSCommon
import Logging
import Networking
import UIKit

final class HomeCoordinator: NSObject,
                             AnyCoordinator,
                             ChildCoordinator,
                             ParentCoordinator,
                             NavigationCoordinator {
    let window: UIWindow
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?
    var childCoordinators = [ChildCoordinator]()
    let analyticsService: AnalyticsService
    private let userStore: UserStorable
    private let tokenHolder = TokenHolder.shared
    private(set) var baseVc: TabbedViewController?
    private weak var reauthCoordinator: ReauthCoordinator?
    
    init(window: UIWindow,
         analyticsService: AnalyticsService,
         userStore: UserStorable) {
        self.window = window
        self.analyticsService = analyticsService
        self.userStore = userStore
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
    
    func updateToken() {
        baseVc?.updateToken(tokenHolder)
        baseVc?.isLoggedIn(true)
        baseVc?.screenAnalytics()
    }
    
    func showDeveloperMenu() {
        let navController = UINavigationController()
        let viewModel = DeveloperMenuViewModel()
        if tokenHolder.accessToken == nil,
           let accessToken = try? userStore.readItem(itemName: .accessToken, storage: .authenticated) {
            tokenHolder.accessToken = accessToken
        }
        let networkClient = NetworkClient(authenticationProvider: tokenHolder)
        let devMenuViewController = DeveloperMenuViewController(viewModel: viewModel,
                                                                networkClient: networkClient) { [unowned self] in
            root.dismiss(animated: true)
            parentCoordinator?.performChildCleanup(child: self)
            let ra = ReauthCoordinator(window: window,
                                       analyticsService: analyticsService,
                                       userStore: userStore)
            openChildModally(ra, animated: true)
            reauthCoordinator = ra
        }
        navController.setViewControllers([devMenuViewController], animated: true)
        root.present(navController, animated: true)
    }
    
    func handleUniversalLink(_ url: URL) {
        reauthCoordinator?.handleUniversalLink(url)
    }
}
