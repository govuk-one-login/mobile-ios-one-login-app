import Coordination
import CRIOrchestrator
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
    
    private var analyticsService: AnalyticsService
    private let networkClient: NetworkClient
    
    init(analyticsService: AnalyticsService,
         networkClient: NetworkClient) {
        self.analyticsService = analyticsService
        self.networkClient = networkClient
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_homeTitle").value,
                                       image: UIImage(systemName: "house"),
                                       tag: 0)
        let criOrchestrator = CRIOrchestrator(analyticsService: analyticsService,
                                              networkClient: networkClient)
        let hc = HomeViewController(analyticsService: analyticsService,
                                    networkClient: networkClient,
                                    criOrchestrator: criOrchestrator)
        root.setViewControllers([hc], animated: true)
    }
    
    func didBecomeSelected() {
        analyticsService.setAdditionalParameters(appTaxonomy: .home)
        let event = IconEvent(textKey: "app_homeTitle")
        analyticsService.logEvent(event)
    }
}
