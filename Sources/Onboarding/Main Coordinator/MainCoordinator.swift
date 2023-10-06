import Coordination
import Foundation
import GDSCommon
import UIKit

final class MainCoordinator: NSObject,
                             NavigationCoordinator {
    private let window: UIWindow
    var root: UINavigationController
    
    init(window: UIWindow, root: UINavigationController) {
        self.window = window
        self.root = root
    }
    
    func start() {
        let viewModel = OneLoginIntroViewModel()
        let viewController = IntroViewController(viewModel: viewModel)
        root.setViewControllers([viewController], animated: false)
    }
}
