import Coordination
import GDSCommon
import Logging
import Networking
import UIKit

final class HomeCoordinator: NSObject,
                             AnyCoordinator,
                             ChildCoordinator,
                             NavigationCoordinator {
    weak var parentCoordinator: ParentCoordinator?
    let root = UINavigationController()
    let analyticsService: AnalyticsService
    private let userStore: UserStorable
    var networkClient: NetworkClient?
    private var tokenHolder: TokenHolder
    private(set) var baseVc: TabbedViewController?
    
    init(analyticsService: AnalyticsService,
         userStore: UserStorable,
         tokenHolder: TokenHolder) {
        self.analyticsService = analyticsService
        self.userStore = userStore
        self.tokenHolder = tokenHolder
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
            let accessToken = try? userStore.secureStoreService.readItem(itemName: .accessToken) {
            tokenHolder.accessToken = accessToken
        }
        networkClient = NetworkClient(authenticationProvider: tokenHolder)
        let devMenuViewController = DeveloperMenuViewController(viewModel: viewModel,
                                                          networkClient: networkClient)
        navController.setViewControllers([devMenuViewController], animated: true)
        root.present(navController, animated: true)
    }
}
