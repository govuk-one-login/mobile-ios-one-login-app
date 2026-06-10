import Coordination
import DesignSystem
import GDSAnalytics
import HTTPLogging
import Logging
import Networking
import SecureStore
import UIKit
import Wallet

@MainActor
final class WalletCoordinator: NSObject,
                               AnyCoordinator,
                               ChildCoordinator,
                               NavigationCoordinator,
                               TabItemCoordinator {
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?
    
    private var analyticsService: OneLoginAnalyticsService
    private let sessionManager: SessionManager
    private let networkingService: OneLoginNetworkingService
    
    private lazy var walletAuthService = LocalAuthServiceWallet(
        walletCoordinator: self,
        analyticsService: analyticsService,
        sessionManager: sessionManager
    )
    
    init(
        analyticsService: OneLoginAnalyticsService,
        networkingService: OneLoginNetworkingService,
        sessionManager: SessionManager
    ) {
        self.analyticsService = analyticsService
        self.networkingService = networkingService
        self.sessionManager = sessionManager
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(
            title: GDSLocalisedString(stringLiteral: "app_tabBarWallet").value,
            image: UIImage(systemName: "wallet.pass"),
            tag: 1
        )
        
        guard let walletStoreID = sessionManager.walletStoreID,
              let walletEnvironment = WalletEnvironment(buildConfiguration: AppEnvironment.buildConfiguration.lowercased()) else {
            // TODO: DCMAW-20468 update this with new error screen with relevant text
            let viewModel = UnrecoverableLoginErrorViewModel(
                analyticsService: analyticsService,
                errorDescription: "walletStoreID or walletEnvironment was not initialised and was nil"
            )
            let walletNotInitialisedErrorScreen = GDSScreen(viewModel: viewModel)
            root.pushViewController(walletNotInitialisedErrorScreen, animated: false)
            return
        }
        
        let walletConfig = WalletConfigV3(
            environment: walletEnvironment,
            clientID: AppEnvironment.stsClientID,
            walletStoreID: walletStoreID
        )
        let walletServices = WalletServices(
            networkClient: WalletNetworkClientWrapper(
                networkingService: networkingService,
                sessionManager: sessionManager
            ),
            localAuthService: walletAuthService,
            txmaLogger: AuthorizedHTTPLogger(
                url: AppEnvironment.txma,
                networkClient: networkingService,
                scope: "mobile.txma-event.write"
            ),
            analyticsService: analyticsService
        )
        WalletSDK.start(
            in: root,
            config: walletConfig,
            services: walletServices
        )
    }
    
    func didBecomeSelected() {
        let tabCoordinator = parentCoordinator as? TabManagerCoordinator
        let isWalletAlreadySelected = tabCoordinator?.isTabAlreadySelected()
       
        WalletSDK.walletTabSelected(isTabAlreadySelected: isWalletAlreadySelected ?? false)
        
        let event = IconEvent(textKey: "app_tabBarWallet")
        analyticsService.logEvent(event)
        tabCoordinator?.updateSelectedTabIndex()
    }
    
    func handleUniversalLink(_ url: URL) {
        WalletSDK.deeplink(with: url)
    }
    
    func userCancelledPasscode() {
        walletAuthService.userCancelled()
    }
}

extension WalletCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        walletAuthService.userCancelled()
    }
}
