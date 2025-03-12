import Coordination
import GDSAnalytics
import GDSCommon
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
    
    private var analyticsService: AnalyticsService
    private let sessionManager: SessionManager
    private let networkClient: NetworkClient
    
    init(analyticsService: AnalyticsService,
         networkClient: NetworkClient,
         sessionManager: SessionManager) {
        self.analyticsService = analyticsService
        self.networkClient = networkClient
        self.sessionManager = sessionManager
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_walletTitle").value,
                                       image: UIImage(systemName: "wallet.pass"),
                                       tag: 1)
        WalletSDK.start(in: root,
                        networkClient: networkClient,
                        analyticsService: analyticsService,
                        localAuthService: DummyLocalAuthService(),
                        credentialIssuer: AppEnvironment.walletCredentialIssuer.absoluteString)
    }
    
    func didBecomeSelected() {
        analyticsService.setAdditionalParameters(appTaxonomy: .wallet)
        let event = IconEvent(textKey: "app_walletTitle")
        analyticsService.logEvent(event)
    }
    
    func handleUniversalLink(_ url: URL) {
        WalletSDK.deeplink(with: url.absoluteString)
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
