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
    private let networkClient: NetworkClient
    
    init(analyticsService: OneLoginAnalyticsService,
         networkClient: NetworkClient) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.home,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        self.networkClient = networkClient
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_homeTitle").value,
                                       image: UIImage(systemName: "house"),
                                       tag: 0)
        let criOrchestrator = CRIOrchestrator(analyticsService: analyticsService,
                                              networkClient: networkClient,
                                              criURLs: OneLoginCRIURLs())
        let hc = HomeViewController(analyticsService: analyticsService,
                                    networkClient: networkClient,
                                    criOrchestrator: criOrchestrator)
        root.setViewControllers([hc], animated: true)
    }
    
    func didBecomeSelected() {
        let event = IconEvent(textKey: "app_homeTitle")
        analyticsService.logEvent(event)
    }
}
