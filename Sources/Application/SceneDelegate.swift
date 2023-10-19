import Authentication
import Networking
import UIKit
import UserDetails

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
        let session = AppAuthSession(window: window!)
        initialiseMainCoordinator(in: window!, session: session)
    }
    
    func initialiseMainCoordinator(in window: UIWindow, session: LoginSession) {
        coordinator = MainCoordinator(window: window, root: navigationController, session: session)
        coordinator?.start()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
