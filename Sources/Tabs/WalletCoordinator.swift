import Coordination
import GDSAnalytics
import GDSCommon
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
    private let networkService: OneLoginNetworkService
    
    private lazy var walletAuthService = LocalAuthServiceWallet(
        walletCoordinator: self,
        analyticsService: analyticsService,
        sessionManager: sessionManager
    )
    
    init(
        analyticsService: OneLoginAnalyticsService,
        networkService: OneLoginNetworkService,
        sessionManager: SessionManager
    ) {
        self.analyticsService = analyticsService
        self.networkService = networkService
        self.sessionManager = sessionManager
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(
            title: GDSLocalisedString(stringLiteral: "app_tabBarWallet").value,
            image: UIImage(systemName: "wallet.pass"),
            tag: 1
        )
        let walletConfig = WalletConfigV2(
            environment: WalletEnvironment(buildConfiguration: AppEnvironment.buildConfiguration.lowercased()),
            clientID: AppEnvironment.stsClientID,
            persistentSessionID: sessionManager.persistentID
        )
        let walletServices = WalletServices(
            networkClient: networkService,
            localAuthService: walletAuthService,
            // TODO: Wrap AuthorizedHTTPLogger with type which conforms to TxMALogger from wallet
            txmaLogger: AuthorizedHTTPLogger(
                url: AppEnvironment.txma,
                networkClient: networkService,
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
