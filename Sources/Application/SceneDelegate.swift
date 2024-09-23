import Authentication
import GAnalytics
import GDSCommon
import LocalAuthentication
import Logging
import Networking
import SecureStore
import UIKit
import Wallet

final class SceneDelegate: UIResponder,
                           UIWindowSceneDelegate,
                           SceneLifecycle {

    private var rootCoordinator: QualifyingCoordinator?

    private lazy var networkClient = NetworkClient()
    private lazy var sessionManager = {
        let manager = PersistentSessionManager()
        networkClient.authorizationProvider = manager.tokenProvider

        manager.registerSessionBoundData(WalletSessionData())
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

    var appBooted = false

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            fatalError("Window failed to initialise in SceneDelegate")
        }
        // TODO: DCMAW-9866 | can we move this into the UI (viewDidAppear?) itself
        trackSplashScreen()

        rootCoordinator = QualifyingCoordinator(
            window: UIWindow(windowScene: windowScene),
            analyticsCenter: analyticsCenter,
            appQualifyingService: appQualifyingService,
            sessionManager: sessionManager,
            networkClient: networkClient
        )
        rootCoordinator?.start()

        setUpBasicUI()
    }
    
    func scene(_ scene: UIScene,
               continue userActivity: NSUserActivity) {
        guard let incomingURL = userActivity.webpageURL else { return }
        rootCoordinator?.handleUniversalLink(incomingURL)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        rootCoordinator?.lock()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        guard appBooted else {
            appBooted = true
            return
        }
        appQualifyingService.initiate()
    }
    
    private func setUpBasicUI() {
        UITabBar.appearance().tintColor = .gdsGreen
        UITabBar.appearance().backgroundColor = .systemBackground
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = .gdsGreen
    }
}
