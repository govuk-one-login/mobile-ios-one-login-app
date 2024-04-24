import Coordination
import UIKit

final class HomeCoordinator: NSObject,
                             AnyCoordinator,
                             ChildCoordinator,
                             NavigationCoordinator {
    var parentCoordinator: ParentCoordinator?
    var root = UINavigationController()
    private var accessToken: String?
    private var baseVc: TokensViewController?

    func start() {
        let tokensViewController = TokensViewController(TokensViewModel {
            self.showDeveloperMenu()
        })
        baseVc = tokensViewController
        root.setViewControllers([tokensViewController], animated: true)
    }
    
    func updateToken(accessToken: String?) {
        baseVc?.updateToken(accessToken: accessToken)
    }
    
    func showDeveloperMenu() {
        let navController = UINavigationController()
        let developerMenuVC = DeveloperMenuViewController()
        navController.setViewControllers([developerMenuVC], animated: true)
        root.present(navController, animated: true)
    }
}
