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
    var appQualifyingService: QualifyingService?
    var appQualifyingManager: QualifyingCoordinator?
    
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
        trackSplashScreen()
        startApp(windowManager: WindowManager(windowScene: windowScene))
        setUpBasicUI()
    }
    
    func scene(_ scene: UIScene,
               continue userActivity: NSUserActivity) {
        guard let incomingURL = userActivity.webpageURL else { return }
        appQualifyingManager?.handleUniversalLink(incomingURL)
    }
    
    func startApp(windowManager: WindowManagement) {
        let analyticsCenter = AnalyticsCenter(analyticsService: analyticsService,
                                              analyticsPreferenceStore: UserDefaultsPreferenceStore())
        appQualifyingService = AppQualifyingService(sessionManager: sessionManager)
        appQualifyingManager = QualifyingCoordinator(windowManager: windowManager,
                                                     analyticsCenter: analyticsCenter,
                                                     appQualifyingService: appQualifyingService!,
                                                     sessionManager: sessionManager)
        appQualifyingService?.delegate = appQualifyingManager
        appQualifyingManager?.start()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        appQualifyingManager?.start()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        appQualifyingService?.initiate()
    }
    
    private func setUpBasicUI() {
        UITabBar.appearance().tintColor = .gdsGreen
        UITabBar.appearance().backgroundColor = .systemBackground
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = .gdsGreen
    }
}
