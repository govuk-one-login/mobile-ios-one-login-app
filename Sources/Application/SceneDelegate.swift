import Authentication
import GAnalytics
import Logging
import SecureStore
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var coordinator: MainCoordinator?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            fatalError("Window failed to initialise in SceneDelegate")
        }
        initialiseMainCoordinator(window: UIWindow(windowScene: windowScene))
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let incomingURL = userActivity.webpageURL,
              let authCoordinator = coordinator?.childCoordinators
            .first(where: { $0 is AuthenticationCoordinator }) as? AuthenticationCoordinator else { return }
        authCoordinator.handleUniversalLink(incomingURL)
    }
    
    func initialiseMainCoordinator(window: UIWindow) {
        let navigationController = UINavigationController()
        let analyticsCentre = AnalyticsCentre(analyticsService: GAnalytics(),
                                              analyticsPreferenceStore: UserDefaultsPreferenceStore())
        coordinator = MainCoordinator(window: window,
                                      root: navigationController,
                                      analyticsCentre: analyticsCentre)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        coordinator?.start()
    }
}
