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
    weak var parentCoordinator: ParentCoordinator?
    let root = UINavigationController()
    let analyticsService: AnalyticsService
    private var tokenHolder: TokenHolder
    private let secureStoreService: SecureStorable
    let walletSDK = WalletSDK()
    
    init(window: UIWindow,
         analyticsService: AnalyticsService,
         tokenHolder: TokenHolder,
         secureStoreService: SecureStorable) {
        self.window = window
        self.analyticsService = analyticsService
        self.tokenHolder = tokenHolder
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
}
