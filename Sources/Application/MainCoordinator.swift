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
    let userStore: UserStorable
    let tokenHolder = TokenHolder()
    private weak var loginCoordinator: LoginCoordinator?

    
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
    
    func evaluateRevisit(action: () -> Void) {
        if userStore.returningAuthenticatedUser {
            do {
                tokenHolder.accessToken = try userStore.secureStoreService.readItem(itemName: .accessToken)
                action()
            } catch {
                print("Error getting token: \(error)")
            }
        } else if tokenHolder.validAccessToken || tokenHolder.accessToken == nil {
            action()
        } else {
            tokenHolder.accessToken = nil
            start()
            action()
        }
    }
    
    func launchTokenCoordinator() {
        guard let accessToken = tokenHolder.accessToken else { return }
        openChildInline(TokenCoordinator(root: root,
                                         accessToken: accessToken))
    }
    
    func didRegainFocus(fromChild child: ChildCoordinator?) {
        switch child {
        case _ as LoginCoordinator:
            launchTokenCoordinator()
        default:
            break
        }
    }
}
