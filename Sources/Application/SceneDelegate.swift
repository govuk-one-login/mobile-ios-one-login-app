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

    private let walletAvailabilityService = WalletAvailabilityService()
    private lazy var networkClient = NetworkClient()
    private lazy var sessionManager = {
        let localAuthentication = LALocalAuthenticationManager(context: LAContext())
        let accessControlEncryptedStore = SecureStoreService.accessControlEncryptedStore(
            localAuthManager: localAuthentication
        )
        
        let manager = PersistentSessionManager(accessControlEncryptedStore: accessControlEncryptedStore,
                                               localAuthentication: localAuthentication)
        networkClient.authorizationProvider = manager.tokenProvider
        
        manager.registerSessionBoundData(accessControlEncryptedStore)
        manager.registerSessionBoundData(WalletSessionData())
        manager.registerSessionBoundData(walletAvailabilityService)
        manager.registerSessionBoundData(analyticsCenter)

        return manager
    }()

    private lazy var appQualifyingService = {
        AppQualifyingService(analyticsService: analyticsService,
                             sessionManager: sessionManager)
    }()

    let analyticsService: AnalyticsService = GAnalytics()
    private lazy var analyticsCenter = {
        AnalyticsCenter(analyticsService: analyticsService,
                        analyticsPreferenceStore: UserDefaultsPreferenceStore())
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
            analyticsCenter: analyticsCenter,
            appQualifyingService: appQualifyingService,
            sessionManager: sessionManager,
            networkClient: networkClient,
            walletAvailabilityService: walletAvailabilityService
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
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        appQualifyingService.initiate()
    }
    
    private func setUpBasicUI() {
        UITabBar.appearance().tintColor = .gdsGreen
        UITabBar.appearance().backgroundColor = .systemBackground
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = .gdsGreen
    }
}
