import Authentication
import Logging
import Coordination
import Foundation
import GDSCommon
import UIKit

final class MainCoordinator: NSObject,
                             NavigationCoordinator {
    private let window: UIWindow
    let root: UINavigationController
    let session: LoginSession
    let analyticsService: AnalyticsService
    let viewControllerFactory: ViewControllerFactory
    
    init(window: UIWindow, 
         root: UINavigationController,
         session: LoginSession,
         analyticsService: AnalyticsService = OneLoginAnalyticsService()) {
        self.window = window
        self.root = root
        self.session = session
        self.analyticsService = analyticsService
        self.viewControllerFactory = ViewControllerFactory(analyticsService: analyticsService)
    }
    
    func start() {
        let introViewController = viewControllerFactory.createIntroViewController(session: session)
        root.setViewControllers([introViewController], animated: false)
    }
}
