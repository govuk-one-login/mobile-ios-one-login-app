import Authentication
import UIKit

@available(iOS 14.0, *)
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
    
    func initialiseMainCoordinator(window: UIWindow) {
        let navigationController = UINavigationController()
        coordinator = MainCoordinator(window: window,
                                      root: navigationController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        coordinator?.start()
    }
}
