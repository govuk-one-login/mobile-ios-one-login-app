import Coordination
import GDSAnalytics
import GDSCommon
import HTTPLogging
import Logging
import Networking
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
    private let networkClient: NetworkClient & WalletNetworkClient
    
    init(analyticsService: OneLoginAnalyticsService,
         networkClient: NetworkClient & WalletNetworkClient,
         sessionManager: SessionManager) {
        self.analyticsService = analyticsService.addingAdditionalParameters([
            OLTaxonomyKey.level2: OLTaxonomyValue.wallet,
            OLTaxonomyKey.level3: OLTaxonomyValue.undefined
        ])
        self.networkClient = networkClient
        self.sessionManager = sessionManager
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_walletTitle").value,
                                       image: UIImage(systemName: "wallet.pass"),
                                       tag: 1)
        let walletServices = WalletServices(
            networkClient: networkClient,
            localAuthService: DummyLocalAuthService(),
            txmaLogger: AuthorizedHTTPLogger(
                url: AppEnvironment.txma,
                networkClient: networkClient,
                scope: "mobile.txma-event.write"
            )
        )
        WalletSDK.start(in: root,
                        config: .oneLoginWalletConfig,
                        services: walletServices,
                        analyticsService: analyticsService)
    }
    
    func didBecomeSelected() {
        let event = IconEvent(textKey: "app_walletTitle")
        analyticsService.logEvent(event)
    }
    
    func handleUniversalLink(_ url: URL) {
        WalletSDK.deeplink(with: url)
    }
    
    func deleteWalletData() throws {
        #if DEBUG
        if AppEnvironment.clearWalletErrorEnabled {
            throw TokenError.expired
        }
        #endif
        try WalletSDK.deleteData()
    }
}
