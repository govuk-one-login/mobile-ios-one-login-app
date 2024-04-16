import Authentication
import GAnalytics
import LocalAuthentication
import Logging
import SecureStore
import UIKit

class SceneDelegate: UIResponder,
                     UIWindowSceneDelegate,
                     SceneLifecycle {
    var coordinator: MainCoordinator?
    let analyticsService: AnalyticsService = GAnalytics()
    var windowManager: WindowManagement?
    private var shouldCallSceneWillEnterForeground = false
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            fatalError("Window failed to initialise in SceneDelegate")
        }
        windowManager = WindowManager(windowScene: windowScene)
        initialiseMainCoordinator(windowManager: windowManager!)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let incomingURL = userActivity.webpageURL else { return }
        coordinator?.handleUniversalLink(incomingURL)
    }
    
    func initialiseMainCoordinator(windowManager: WindowManagement) {
        let tabController = UITabBarController()
        let analyticsCenter = AnalyticsCenter(analyticsService: analyticsService,
                                              analyticsPreferenceStore: UserDefaultsPreferenceStore())
        let secureStoreService = SecureStoreService(configuration: .init(id: .oneLoginTokens,
                                                                         accessControlLevel: .currentBiometricsOrPasscode,
                                                                         localAuthStrings: LAContext().contextStrings))
        let userStore = UserStorage(secureStoreService: secureStoreService,
                                    defaultsStore: UserDefaults.standard)
        coordinator = MainCoordinator(windowManager: windowManager,
                                      root: tabController,
                                      analyticsCenter: analyticsCenter,
                                      userStore: userStore)
        windowManager.appWindow.rootViewController = tabController
        windowManager.appWindow.makeKeyAndVisible()
        trackSplashScreen(analyticsCenter.analyticsService)
        coordinator?.start()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        displayUnlockScreen()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        if shouldCallSceneWillEnterForeground {
            promptToUnlock()
        } else {
            shouldCallSceneWillEnterForeground = true
        }
    }
}
