import Authentication
import GAnalytics
import Logging
import SecureStore
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var windowScene: UIWindowScene?
    var coordinator: MainCoordinator?
    let analyticsService = GAnalytics()
    private var unlockWindow: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            fatalError("Window failed to initialise in SceneDelegate")
        }
        self.windowScene = windowScene
        initialiseMainCoordinator(window: UIWindow(windowScene: windowScene))
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let incomingURL = userActivity.webpageURL else { return }
        coordinator?.handleUniversalLink(incomingURL)
    }
    
    func initialiseMainCoordinator(window: UIWindow) {
        let navigationController = UINavigationController()
        let analyticsCentre = AnalyticsCentre(analyticsService: analyticsService,
                                              analyticsPreferenceStore: UserDefaultsPreferenceStore())
        coordinator = MainCoordinator(window: window,
                                      root: navigationController,
                                      analyticsCentre: analyticsCentre)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        coordinator?.start()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        guard let windowScene else { return }
        unlockWindow = UIWindow(windowScene: windowScene)
        let unlockScreenViewModel = ReturnUnlockScreenViewModel(analyticsService: analyticsService)
        unlockWindow?.rootViewController = UnlockScreenViewController(viewModel: unlockScreenViewModel)
        unlockWindow?.windowLevel = .alert
        unlockWindow?.makeKeyAndVisible()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        coordinator?.evaluateRevisit {
            unlockWindow?.isHidden = true
            unlockWindow = nil
        }
    }
}
