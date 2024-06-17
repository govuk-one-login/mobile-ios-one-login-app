import Authentication
import GAnalytics
import GDSCommon
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
    private lazy var userStore: UserStorable = {
        let secureStoreService = SecureStoreService(configuration: .init(id: .oneLoginTokens,
                                                                         accessControlLevel: .currentBiometricsOrPasscode,
                                                                         localAuthStrings: LAContext().contextStrings))
        return UserStorage(secureStoreService: secureStoreService,
                                    defaultsStore: UserDefaults.standard)
    }()

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            fatalError("Window failed to initialise in SceneDelegate")
        }
        windowManager = WindowManager(windowScene: windowScene)
        setUpBasicUI()
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
       if userStore.returningAuthenticatedUser {
           shouldCallSceneWillEnterForeground = true
           displayUnlockScreen()
       }
   }

    func sceneWillEnterForeground(_ scene: UIScene) {
        if shouldCallSceneWillEnterForeground {
            promptToUnlock()
        }
    }
    
    private func setUpBasicUI() {
        UITabBar.appearance().tintColor = .gdsGreen
        UITabBar.appearance().backgroundColor = .systemBackground
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = .gdsGreen
    }
}
