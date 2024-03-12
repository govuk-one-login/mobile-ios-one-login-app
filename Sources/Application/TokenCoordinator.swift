import Authentication
import Coordination
import UIKit

final class TokenCoordinator: NSObject,
                              ChildCoordinator,
                              NavigationCoordinator {
    let root: UINavigationController
    var parentCoordinator: ParentCoordinator?
    let tokenHolder: TokenHolder
    
    init(root: UINavigationController,
         tokenHolder: TokenHolder) {
        self.root = root
        self.tokenHolder = tokenHolder
    }
    
    func start() {
        guard let tokenResponse = tokenHolder.tokenResponse else { return }
        let vc = TokensViewController(tokens: tokenResponse)
        vc.navigationItem.hidesBackButton = true
        root.pushViewController(vc, animated: true)
    }
}
