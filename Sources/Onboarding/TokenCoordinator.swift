import Authentication
import Coordination
import UIKit

final class TokenCoordinator: NSObject,
                              ChildCoordinator,
                              NavigationCoordinator {
    let root: UINavigationController
    var parentCoordinator: ParentCoordinator?
    let tokens: TokenResponse

    init(root: UINavigationController,
         tokens: TokenResponse) {
        self.root = root
        self.tokens = tokens
    }

    func start() {
        root.isNavigationBarHidden = true
        let vc = TokensViewController(tokens: tokens)
        self.root.pushViewController(vc, animated: true)
    }
}
