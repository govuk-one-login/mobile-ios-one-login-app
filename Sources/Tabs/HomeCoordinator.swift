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
    var networkClient: RequestAuthorizing?
    private let userStore: UserStorable
    private var tokenHolder: TokenHolder?
    private(set) var baseVc: TabbedViewController?
    
    init(analyticsService: AnalyticsService,
         userStore: UserStorable) {
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
    
    func updateToken(_ token: TokenHolder) {
        baseVc?.updateToken(token)
        baseVc?.screenAnalytics()
        self.tokenHolder = token
    }
    
    func showDeveloperMenu() {
        let navController = UINavigationController()
        let devMenuViewModel = DeveloperMenuViewModel()
        if tokenHolder?.accessToken == nil,
            let accessToken = try? userStore.secureStoreService.readItem(itemName: .accessToken) {
            tokenHolder?.accessToken = accessToken
        }
        networkClient = NetworkClient(authenticationProvider: tokenHolder)
        let developerMenuVC = DeveloperMenuViewController(viewModel: devMenuViewModel,
                                                          networkClient: networkClient)
        navController.setViewControllers([developerMenuVC], animated: true)
        root.present(navController, animated: true)
    }
}
