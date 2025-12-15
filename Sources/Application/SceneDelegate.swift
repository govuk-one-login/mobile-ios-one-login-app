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
        let analyticsService = GAnalyticsV2(analyticsPreferenceStore: analyticsPreferenceStore)
            .addingAdditionalParameters(.oneLoginDefaults)
        analyticsService.activate()
        return analyticsService
    }()
    private lazy var appQualifyingService = AppQualifyingService(analyticsService: analyticsService,
                                                                 sessionManager: sessionManager)
    private lazy var networkClient = NetworkClient()
    private lazy var networkingService = NetworkingService(
        networkClient: networkClient,
        sessionManager: sessionManager
    )

    private lazy var sessionManager = {
        do {
            let accessControlEncryptedSecureStoreMigrator = try AccessControlEncryptedSecureStoreMigrator(analyticsService: analyticsService)
            let encryptedSecureStoreMigrator = EncryptedSecureStoreMigrator(analyticsService: analyticsService)
            let manager = PersistentSessionManager(
                accessControlEncryptedStore: accessControlEncryptedSecureStoreMigrator,
                encryptedStore: encryptedSecureStoreMigrator
            )
            networkClient.authorizationProvider = manager.tokenProvider
            
            manager.registerSessionBoundData(
                [
                    WalletSessionData(),
                    WalletAvailabilityService(),
                    analyticsPreferenceStore,
                    accessControlEncryptedSecureStoreMigrator,
                    encryptedSecureStoreMigrator,
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
