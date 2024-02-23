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
        root.isNavigationBarHidden = true
        guard let tokenResponse = tokenHolder.tokenResponse else { return }
        let vc = TokensViewController(tokens: tokenResponse)
        root.pushViewController(vc, animated: true)
//        print(UserDefaults.standard.object(forKey: "returningUser") as? Bool)
//        print(UserDefaults.standard.object(forKey: "accessTokenExpiry") as? Date)
//        print(UserDefaults.standard.object(forKey: "accessToken"))
    }
}
