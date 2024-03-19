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
    let userStore: UserStorable
    let tokenHolder = TokenHolder()
    
    init(window: UIWindow,
         root: UINavigationController,
         analyticsCentre: AnalyticsCentral,
         secureStoreService: SecureStorable = SecureStoreService(configuration: .init(id: .oneLoginTokens,
                                                                                      accessControlLevel: .currentBiometricsOrPasscode,
                                                                                      localAuthStrings: LAContext().contextStrings)),
         defaultsStore: DefaultsStorable = UserDefaults.standard) {
        self.window = window
        self.root = root
        self.analyticsCentre = analyticsCentre
        self.userStore = UserStorage(secureStoreService: secureStoreService,
                                     defaultsStore: defaultsStore)
    }
    
    func start() {
        let lc = LoginCoordinator(window: window,
                                  root: root,
                                  analyticsCentre: analyticsCentre,
                                  userStore: userStore,
                                  tokenHolder: tokenHolder)
        openChildInline(lc)
        self.loginCoordinator = lc
    }
    
    func handleUniversalLink(_ url: URL) {
        loginCoordinator?.handleUniversalLink(url)
    }
    
    func evaluateRevisit() -> Bool {
        if userStore.returningAuthenticatedUser {
            do {
                _ = try userStore.secureStoreService.readItem(itemName: .accessToken)
                return true
            } catch {
                start()
            }
        } else if tokenHolder.validAccessToken {
            return true
        } else {
            start()
        }
        return false
        
//        if userStore.returningAuthenticatedUser {
//            if let _ = try? userStore.secureStoreService.readItem(itemName: .accessToken) {
//                return true
//            } else {
//                return false
//            }
//        } else if tokenHolder.validAccessToken {
//            return true
//        } else {
//            return false
//        }
        
        // if userStore.returningAuthenticatedUser, local auth
        // OR tokenHolder.validAccessToken, true
        // if false, login flow
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
