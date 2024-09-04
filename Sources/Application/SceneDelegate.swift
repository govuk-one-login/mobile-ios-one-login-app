import Authentication
import GAnalytics
import GDSCommon
import LocalAuthentication
import Logging
import Networking
import SecureStore
import UIKit

class SceneDelegate: UIResponder,
                     UIWindowSceneDelegate,
                     SceneLifecycle {
    var windowManager: WindowManagement?
    var appQualifyingManager: AppQualifyingManager?
    var coordinator: MainCoordinator?
    private var shouldCallSceneWillEnterForeground = false
    
    private lazy var client = NetworkClient()
    private lazy var sessionManager = {
        let manager = PersistentSessionManager()
        self.client.authorizationProvider = manager.tokenProvider
        return manager
    }()

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            fatalError("Window failed to initialise in SceneDelegate")
        }
        trackSplashScreen(analyticsService)
        windowManager = WindowManager(windowScene: windowScene)
        let analyticsCenter = AnalyticsCenter(analyticsService: analyticsService,
                                              analyticsPreferenceStore: UserDefaultsPreferenceStore())
        appQualifyingManager = AppQualifyingManager(windowManager: windowManager!,
                                                    appQualifyingService: <#AppQualifyingService#>,
                                                    analyticsCenter: analyticsCenter,
                                                    sessionManager: sessionManager)
        appQualifyingManager?.start()
        setUpBasicUI()
    }
    
    func scene(_ scene: UIScene,
               continue userActivity: NSUserActivity) {
        guard let incomingURL = userActivity.webpageURL else { return }
        coordinator?.handleUniversalLink(incomingURL)
    }
    
    func startMainCoordinator() {
        let tabController = UITabBarController()
        let analyticsCenter = AnalyticsCenter(analyticsService: analyticsService,
                                              analyticsPreferenceStore: UserDefaultsPreferenceStore())
        coordinator = MainCoordinator(windowManager: windowManager!,
                                      root: tabController,
                                      analyticsCenter: analyticsCenter,
                                      networkClient: client,
                                      sessionManager: sessionManager)
        windowManager?.appWindow.rootViewController = tabController
        windowManager?.appWindow.makeKeyAndVisible()
        trackSplashScreen(analyticsCenter.analyticsService)
        coordinator?.start()
        windowManager?.hideUnlockWindow()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        if sessionManager.isSessionValid {
            displayUnlockScreen()
            shouldCallSceneWillEnterForeground = true
        } else {
            shouldCallSceneWillEnterForeground = false
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        if shouldCallSceneWillEnterForeground {
            coordinator?.evaluateRevisit()
        }
    }
    
    private func setUpBasicUI() {
        UITabBar.appearance().tintColor = .gdsGreen
        UITabBar.appearance().backgroundColor = .systemBackground
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = .gdsGreen
    }
}
