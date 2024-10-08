import Coordination
import GDSCommon
import LocalAuthentication
import Logging
import Networking
import SecureStore
import UIKit
import Wallet

@MainActor
final class WalletCoordinator: NSObject,
                               AnyCoordinator,
                               ChildCoordinator,
                               NavigationCoordinator {
    private let window: UIWindow
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?
    private var analyticsCenter: AnalyticsCentral
    private let sessionManager: SessionManager

    private let networkClient: NetworkClient

    init(window: UIWindow,
         analyticsCenter: AnalyticsCentral,
         networkClient: NetworkClient,
         sessionManager: SessionManager) {
        self.window = window
        self.analyticsCenter = analyticsCenter
        self.networkClient = networkClient
        self.sessionManager = sessionManager
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_walletTitle").value,
                                       image: UIImage(systemName: "wallet.pass"),
                                       tag: 1)
        WalletSDK.start(in: root,
                        networkClient: networkClient,
                        analyticsService: analyticsCenter.analyticsService,
                        localAuthService: DummyLocalAuthService(),
                        credentialIssuer: AppEnvironment.walletCredentialIssuer)
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
