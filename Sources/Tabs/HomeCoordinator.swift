import Coordination
import CRIOrchestrator
import GAnalytics
import GDSAnalytics
import GDSCommon
import Logging
import Networking
import UIKit

@MainActor
final class HomeCoordinator: NSObject,
                             AnyCoordinator,
                             ChildCoordinator,
                             NavigationCoordinator,
                             TabItemCoordinator {
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?
    
    private var analyticsService: OneLoginAnalyticsService
    private let networkingService: OneLoginNetworkingService
    
    init(
        analyticsService: OneLoginAnalyticsService,
        networkingService: OneLoginNetworkingService
    ) {
        self.analyticsService = analyticsService
        self.networkingService = networkingService
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(
            title: GDSLocalisedString(stringLiteral: "app_homeTitle").value,
            image: UIImage(systemName: "house"),
            tag: 0
        )
        let criOrchestrator = CRIOrchestrator(
            analyticsService: analyticsService,
            networkClient: networkingService,
            criURLs: OneLoginCRIURLs()
        )
        let hc = HomeViewController(
            analyticsService: analyticsService,
            criOrchestrator: criOrchestrator
        )
        root.setViewControllers([hc], animated: true)
    }
    
    func didBecomeSelected() {
        let event = IconEvent(textKey: "app_homeTitle")
        analyticsService.logEvent(event)
        let tabCoordinator = (parentCoordinator as? TabManagerCoordinator)
        tabCoordinator?.updateSelectedTabIndex()
    }
}
