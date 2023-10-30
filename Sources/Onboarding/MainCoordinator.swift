import Authentication
import Coordination
import Foundation
import GDSCommon
import Logging
import UIKit

final class MainCoordinator: NSObject,
                             NavigationCoordinator {
    private let window: UIWindow
    let root: UINavigationController
    let session: LoginSession
    let analyticsService: AnalyticsService
    private let viewControllerFactory = OnboardingViewControllerFactory.self
    
    init(window: UIWindow,
         root: UINavigationController,
         session: LoginSession,
         analyticsService: AnalyticsService = OneLoginAnalyticsService()) {
        self.window = window
        self.root = root
        self.session = session
        self.analyticsService = analyticsService
    }
    
    func start() {
        let introViewController = viewControllerFactory.createIntroViewController(analyticsService: analyticsService,
                                                                                  session: session)
        root.setViewControllers([introViewController], animated: false)
    }
}
