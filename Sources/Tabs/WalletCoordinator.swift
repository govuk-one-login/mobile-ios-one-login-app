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
    private let secureStoreService: SecureStorable
    private var tokenHolder: TokenHolder?
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
        if tokenHolder?.accessToken == nil,
           let accessToken = try? secureStoreService.readItem(itemName: .accessToken) {
            tokenHolder?.accessToken = accessToken
        }
        let networkClient = NetworkClient(authenticationProvider: tokenHolder)
        walletSDK.start(in: window,
                        with: root,
                        networkClient: networkClient,
                        analyticsService: analyticsService,
                        persistentSecureStore: secureStoreService)
    }
    
    func updateToken(_ token: TokenHolder) {
        tokenHolder = token
    }
}
