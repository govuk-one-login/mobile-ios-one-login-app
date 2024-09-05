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
    var appQualifyingManager: QualifyingCoordinator?
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
        startApp()
        setUpBasicUI()
    }
    
    func scene(_ scene: UIScene,
               continue userActivity: NSUserActivity) {
//        guard let incomingURL = userActivity.webpageURL else { return }
//        coordinator?.handleUniversalLink(incomingURL)
    }
    
    func startApp() {
        let analyticsCenter = AnalyticsCenter(analyticsService: analyticsService,
                                              analyticsPreferenceStore: UserDefaultsPreferenceStore())
        appQualifyingManager = QualifyingCoordinator(windowManager: windowManager!,
                                                     appQualifyingService: AppQualifyingService(sessionManager: sessionManager),
                                                     analyticsCenter: analyticsCenter,
                                                     sessionManager: sessionManager)
        appQualifyingManager?.start()
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
//            coordinator?.evaluateRevisit()
        }
    }
    
    private func setUpBasicUI() {
        UITabBar.appearance().tintColor = .gdsGreen
        UITabBar.appearance().backgroundColor = .systemBackground
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = .gdsGreen
    }
}
