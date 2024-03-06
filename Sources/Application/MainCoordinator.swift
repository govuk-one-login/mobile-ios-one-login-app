import Authentication
import Coordination
import GAnalytics
import Logging
import SecureStore
import UIKit

final class MainCoordinator: NSObject,
                             AnyCoordinator,
                             ParentCoordinator,
                             NavigationCoordinator {
    let window: UIWindow
    let root: UINavigationController
    let analyticsCentre: AnalyticsCentral
    var childCoordinators = [ChildCoordinator]()
    let tokenHolder = TokenHolder()

    init(window: UIWindow,
         root: UINavigationController,
         analyticsCentre: AnalyticsCentral) {
        self.window = window
        self.root = root
        self.analyticsCentre = analyticsCentre
    }
    
    func start() {
        openChildInline(LoginCoordinator(window: window,
                                         root: root,
                                         analyticsCentre: analyticsCentre,
                                         defaultStore: UserDefaults.standard,
                                         tokenHolder: tokenHolder))
    }
    
    func didRegainFocus(fromChild child: ChildCoordinator?) {
        switch child {
        case _ as LoginCoordinator:
            guard let accessToken = tokenHolder.tokenResponse?.accessToken else { return }
//            launchHomeCoordinator(token: accessToken)
        default:
            break
        }
    }
}
