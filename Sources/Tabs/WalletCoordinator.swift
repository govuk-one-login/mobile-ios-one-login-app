import Coordination
import GDSCommon
import Logging
import Networking
import SecureStore
import UIKit
import Wallet

final class WalletCoordinator: NSObject,
                               AnyCoordinator,
                               ChildCoordinator,
                               NavigationCoordinator {
    let window: UIWindow
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?
    let analyticsService: AnalyticsService
    private let secureStoreService: SecureStorable
    private let tokenHolder = TokenHolder.shared
    let walletSDK = WalletSDK()
    
    init(window: UIWindow,
         analyticsService: AnalyticsService,
         secureStoreService: SecureStorable) {
        self.window = window
        self.analyticsService = analyticsService
        self.secureStoreService = secureStoreService
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_walletTitle").value,
                                       image: UIImage(systemName: "wallet.pass"),
                                       tag: 1)
    }
    
    func updateToken() {
        let networkClient = NetworkClient(authenticationProvider: tokenHolder)
        walletSDK.start(in: window,
                        with: root,
                        networkClient: networkClient,
                        analyticsService: analyticsService,
                        persistentSecureStore: secureStoreService)

    }
    
    func clearWallet() throws {
        try walletSDK.deleteWalletData()
    }
}
