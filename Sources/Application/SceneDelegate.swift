import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var coordinator: MainCoordinator?
    let navigationController = UINavigationController()

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            fatalError("Window failed to initialise in SceneDelegate")
        }
        window = UIWindow(windowScene: windowScene)
        initialiseMainCoordinator(in: window!)
    }
    
    func initialiseMainCoordinator(in window: UIWindow) {
        coordinator = MainCoordinator(window: window, root: navigationController)
        coordinator?.start()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
