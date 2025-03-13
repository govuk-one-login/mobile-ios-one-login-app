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
    
    private var analyticsService: AnalyticsService & WalletAnalyticsService
    private let sessionManager: SessionManager
    private let networkClient: NetworkClient & WalletNetworkClient
    
    init(analyticsService: AnalyticsService & WalletAnalyticsService,
         networkClient: NetworkClient & WalletNetworkClient,
         sessionManager: SessionManager) {
        self.analyticsService = analyticsService
        self.networkClient = networkClient
        self.sessionManager = sessionManager
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_walletTitle").value,
                                       image: UIImage(systemName: "wallet.pass"),
                                       tag: 1)
        let walletConfig = WalletConfig(
            environment: WalletEnvironment(rawValue: AppEnvironment.buildConfiguration.lowercased()),
            credentialIssuer: AppEnvironment.walletCredentialIssuer.absoluteString,
            clientID: AppEnvironment.stsClientID
        )
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
                        config: walletConfig,
                        services: walletServices,
                        analyticsService: analyticsService)
    }
    
    func didBecomeSelected() {
        analyticsService.setAdditionalParameters(appTaxonomy: .wallet)
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
