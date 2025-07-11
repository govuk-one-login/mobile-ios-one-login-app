import GAnalytics
import LocalAuthentication
import Logging
import Networking
import SecureStore
import UIKit

final class SceneDelegate: UIResponder,
                           UIWindowSceneDelegate,
                           SceneLifecycle {
    private var rootCoordinator: QualifyingCoordinator?
    
    lazy var analyticsService: OneLoginAnalyticsService = {
        let analyticsService = GAnalyticsV2().addingAdditionalParameters(.oneLoginDefaults)
        analyticsService.configure()
        return analyticsService
    }()
    private lazy var analyticsPreferenceStore = UserDefaultsPreferenceStore()
    private lazy var appQualifyingService = AppQualifyingService(analyticsService: analyticsService,
                                                                 sessionManager: sessionManager)
    private lazy var networkClient = NetworkClient()
    private lazy var sessionManager = {
        do {
            let secureStoreManager = try OneLoginSecureStoreManager()
            let manager = PersistentSessionManager(secureStoreManager: secureStoreManager)
            networkClient.authorizationProvider = manager.tokenProvider
            
            manager.registerSessionBoundData(
                [
                    WalletSessionData(),
                    WalletAvailabilityService(),
                    analyticsPreferenceStore,
                    UserDefaults.standard
                ]
            )
            return manager
        } catch {
            fatalError()
        }
    }()
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            fatalError("Window failed to initialise in SceneDelegate")
        }
        // TODO: DCMAW-9866 | can we move this into the UI (viewDidAppear?) itself
        trackSplashScreen()
        
        rootCoordinator = QualifyingCoordinator(
            appWindow: UIWindow(windowScene: windowScene),
            appQualifyingService: appQualifyingService,
            analyticsService: analyticsService,
            analyticsPreferenceStore: analyticsPreferenceStore,
            sessionManager: sessionManager,
            networkClient: networkClient
        )
        rootCoordinator?.start()
        setUpBasicUI()
        
        if let deepLink = connectionOptions.userActivities.first?.webpageURL {
            rootCoordinator?.handleUniversalLink(deepLink)
        }
    }
    
    func scene(_ scene: UIScene,
               continue userActivity: NSUserActivity) {
        guard let incomingURL = userActivity.webpageURL else { return }
        rootCoordinator?.handleUniversalLink(incomingURL)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        rootCoordinator?.displayUnlockWindow()
        rootCoordinator?.unlockViewController.isLoading = true
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        appQualifyingService.initiate()
    }
    
    private func setUpBasicUI() {
        UITabBar.appearance().tintColor = .accent
        UITabBar.appearance().backgroundColor = .systemBackground
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = .accent
    }
}
