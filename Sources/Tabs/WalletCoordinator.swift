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
    private let window: UIWindow
    let root = UINavigationController()
    weak var parentCoordinator: ParentCoordinator?
    private let analyticsService: AnalyticsService
    private let userStore: UserStorable
    private let walletSDK = WalletSDK()
    private var networkClient = NetworkClient(authenticationProvider: TokenHolder.shared)
    
    init(window: UIWindow,
         analyticsService: AnalyticsService,
         userStore: UserStorable) {
        self.window = window
        self.analyticsService = analyticsService
        self.userStore = userStore
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_walletTitle").value,
                                       image: UIImage(systemName: "wallet.pass"),
                                       tag: 1)
        walletSDK.start(in: window,
                        with: root,
                        networkClient: networkClient,
                        analyticsService: analyticsService,
                        persistentSecureStore: userStore.openStore)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(clearWallet),
                         name: Notification.Name(.clearWallet),
                         object: nil)
    }
    
    func updateToken() {
        networkClient = NetworkClient(authenticationProvider: TokenHolder.shared)
    }
    
    func handleUniversalLink(_ url: URL) {
        walletSDK.deeplink(with: url.absoluteString)
    }
    
    func deleteWalletData() throws {
        try walletSDK.deleteWalletData()
    }
    
    @objc private func clearWallet() {
        do {
            try deleteWalletData()
            userStore.resetPersistentSession()
        } catch {
            let unableToLoginErrorScreen = ErrorPresenter
                .createUnableToLoginError(errorDescription: error.localizedDescription,
                                          analyticsService: analyticsService) {
                    exit(0)
                }
            unableToLoginErrorScreen.modalPresentationStyle = .overFullScreen
            window.rootViewController?.dismiss(animated: false)
            window.rootViewController?.present(unableToLoginErrorScreen, animated: false)
        }
    }
}
