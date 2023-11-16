import Authentication
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
        let session = AppAuthSession(window: window!)
        initialiseMainCoordinator(session: session)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let incomingURL = userActivity.webpageURL {
            coordinator?.authCoordinator?.handleUniversalLink(incomingURL)
        }
    }
    
    func initialiseMainCoordinator(session: LoginSession) {
        coordinator = MainCoordinator(root: navigationController,
                                      session: session)
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
        coordinator?.start()
    }
}
