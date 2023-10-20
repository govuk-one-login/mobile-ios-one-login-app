import Authentication
import Coordination
import Foundation
import GDSCommon
import Networking
import UIKit
import UserDetails

final class MainCoordinator: NSObject,
                             NavigationCoordinator {
    private let window: UIWindow
    let root: UINavigationController
    let session: LoginSession
    let viewControllerFactory = ViewControllerFactory()
    
    init(window: UIWindow, root: UINavigationController, session: LoginSession) {
        self.window = window
        self.root = root
        self.session = session
    }
    
    func start() {
        let introViewController = viewControllerFactory.createIntroViewController(session: session)
        root.setViewControllers([introViewController], animated: false)
    }
}
