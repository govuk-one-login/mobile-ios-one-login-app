import AppIntegrity
import DesignSystem
import GAnalytics
import LocalAuthentication
import LocalAuthenticationWrapper
import Logging
import Networking
import SecureStore
import UIKit

final class SceneDelegate: UIResponder,
                           UIWindowSceneDelegate,
                           SceneLifecycle {
    private var rootCoordinator: QualifyingCoordinator?
    
    private lazy var analyticsPreferenceStore = UserDefaultsPreferenceStore()
    lazy var analyticsService: OneLoginAnalyticsService = {
        let analyticsService = GAnalytics(analyticsPreferenceStore: analyticsPreferenceStore)
            .addingAdditionalParameters(.oneLoginDefaults)
        analyticsService.activate()
        return analyticsService
    }()
    
    private lazy var refreshTokenExchangeManager: RefreshTokenExchangeManager = RefreshTokenExchangeManager()
    private lazy var appQualifyingService = AppQualifyingService(analyticsService: analyticsService,
                                                                 sessionManager: sessionManager)
    private lazy var serialTaskQueue: SerialTaskQueue = SerialTaskQueue()
    private lazy var networkingService = NetworkingService(refreshExchangeManager: refreshTokenExchangeManager,
                                                           sessionManager: sessionManager,
                                                           serialTaskQueue: serialTaskQueue)
    private lazy var sessionManager: PersistentSessionManager = {
        do {
            return try .make(analyticsService: analyticsService,
                             refreshTokenExchangeManager: refreshTokenExchangeManager,
                             serialTaskQueue: serialTaskQueue,
                             analyticsPreferenceStore: analyticsPreferenceStore)
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
            sessionManager: sessionManager,
            networkingService: networkingService
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
    
    func setUpBasicUI() {
        // Selected TabBar color
        UITabBar.appearance().tintColor =
            DesignSystem.Color.NavigationElements.selectedTabIconAndLabel
        
        // Default TabBar color
        UITabBar.appearance().unselectedItemTintColor = UIColor(
            light: DesignSystem.Color.Buttons.primaryForegroundDisabled,
            dark: DesignSystem.Color.Buttons.primaryBackgroundDisabled
        )
        UITabBar.appearance().backgroundColor = .systemBackground
        
        if #unavailable(iOS 26.0) {
            // Apply navigation bar button item color to iOS lower than 26
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = .accent
        }
    }
}
