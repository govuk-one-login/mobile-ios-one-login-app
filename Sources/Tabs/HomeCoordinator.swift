import Coordination
import CRIOrchestrator
import GAnalytics
import GDSAnalytics
import GDSCommon
import Logging
import Networking
import UIKit

struct OneLoginCRIURLs: CRIURLs {
    let criBaseURL: URL = URL(string: "google.co.uk")!
    let govSupportURL: URL = URL(string: "google.co.uk")!
    let handoffURL: URL = URL(string: "google.co.uk")!
    let baseURL: URL = URL(string: "google.co.uk")!
    let domainURL: URL = URL(string: "google.co.uk")!
    let govUKURL: URL = URL(string: "google.co.uk")!
    let readIDURLString: String = "google.co.uk"
    let iProovURLString: String = "google.co.uk"
}

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
        self.analyticsService = analyticsService
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
        analyticsService.setAdditionalParameters(appTaxonomy: .home)
        let event = IconEvent(textKey: "app_homeTitle")
        analyticsService.logEvent(event)
    }
}
