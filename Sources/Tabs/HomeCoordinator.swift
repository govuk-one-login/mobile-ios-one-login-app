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
    let window: UIWindow
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?
    var childCoordinators = [ChildCoordinator]()
    let analyticsService: AnalyticsService
    private let userStore: UserStorable
    
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
        baseVc?.updateToken(TokenHolder.shared)
        baseVc?.isLoggedIn(true)
        baseVc?.screenAnalytics()
    }
    
    func showDeveloperMenu() {
        if TokenHolder.shared.accessToken == nil,
           let accessToken = try? userStore.readItem(itemName: .accessToken, storage: .authenticated) {
            TokenHolder.shared.accessToken = accessToken
        }
        let networkClient = NetworkClient(authenticationProvider: TokenHolder.shared)
        let viewModel = DeveloperMenuViewModel()
        let devMenuViewController = DeveloperMenuViewController(parentCoordinator: self,
                                                                viewModel: viewModel,
                                                                userStore: userStore,
                                                                networkClient: networkClient)
        let navController = UINavigationController()
        navController.setViewControllers([devMenuViewController], animated: false)
        root.present(navController, animated: true)
    }
    
    func accessTokenInvalidAction() {
        MainCoordinator.isReauthing = true
        root.dismiss(animated: true)
        TokenHolder.shared.clearTokenHolder()
        userStore.refreshStorage(accessControlLevel: nil)
        let rc = ReauthCoordinator(window: window,
                                   analyticsService: analyticsService,
                                   userStore: userStore)
        openChildModally(rc, animated: true)
        reauthCoordinator = rc
    }
    
    func handleUniversalLink(_ url: URL) {
        reauthCoordinator?.handleUniversalLink(url)
    }
}

extension HomeCoordinator: ParentCoordinator {
    func didRegainFocus(fromChild child: ChildCoordinator?) {
        if child is ReauthCoordinator {
            parentCoordinator?.performChildCleanup(child: self)
        }
    }
}
