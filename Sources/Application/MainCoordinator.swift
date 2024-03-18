import Coordination
import LocalAuthentication
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
    private weak var loginCoordinator: LoginCoordinator?
    
    init(window: UIWindow,
         root: UINavigationController,
         analyticsCentre: AnalyticsCentral) {
        self.window = window
        self.root = root
        self.analyticsCentre = analyticsCentre
    }
    
    func start() {
        let secureStoreService = SecureStoreService(configuration: .init(id: .oneLoginTokens,
                                                                         accessControlLevel: .currentBiometricsOrPasscode,
                                                                         localAuthStrings: LAContext().contextStrings))
        let lc = LoginCoordinator(window: window,
                                  root: root,
                                  analyticsCentre: analyticsCentre,
                                  secureStoreService: secureStoreService,
                                  defaultStore: UserDefaults.standard)
        openChildInline(lc)
        self.loginCoordinator = lc
    }
    
    func handleUniversalLink(_ url: URL) {
        loginCoordinator?.handleUniversalLink(url)
    }
    
    func launchTokenCoordinator(tokenHolder: TokenHolder) {
        guard let accessToken = tokenHolder.accessToken else { return }
        openChildInline(TokenCoordinator(root: root,
                                         accessToken: accessToken))
    }
    
    func didRegainFocus(fromChild child: ChildCoordinator?) {
        switch child {
        case let child as LoginCoordinator where child.tokenHolder.accessToken != nil:
            launchTokenCoordinator(tokenHolder: child.tokenHolder)
        default:
            break
        }
    }
}
