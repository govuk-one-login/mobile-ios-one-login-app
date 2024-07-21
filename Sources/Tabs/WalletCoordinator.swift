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
    var analyticsCenter: AnalyticsCentral
    private let secureStoreService: SecureStorable
    let walletSDK = WalletSDK()
    
    init(window: UIWindow,
         analyticsCenter: AnalyticsCentral,
         secureStoreService: SecureStorable) {
        self.window = window
        self.analyticsCenter = analyticsCenter
        self.secureStoreService = secureStoreService
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_walletTitle").value,
                                       image: UIImage(systemName: "wallet.pass"),
                                       tag: 1)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(clearWallet),
                         name: Notification.Name(.clearWallet),
                         object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(clearWalletAndAnalytics),
                         name: Notification.Name(.clearWalletAndAnalytics),
                         object: nil)
    }
    
    func updateToken() {
        let networkClient = NetworkClient(authenticationProvider: TokenHolder.shared)
        walletSDK.start(in: window,
                        with: root,
                        networkClient: networkClient,
                        analyticsService: analyticsCenter.analyticsService,
                        persistentSecureStore: secureStoreService)

    }
    
    func deleteWalletData() throws {
        try walletSDK.deleteWalletData()
    }
    
    @objc func clearWallet() {
        do {
            try deleteWalletData()
        } catch {
            showSignOutErrorScreen(error: error)
        }
    }
    
    @objc func clearWalletAndAnalytics() {
        do {
            try deleteWalletData()
            analyticsCenter.analyticsPreferenceStore.hasAcceptedAnalytics = nil
        } catch {
            showSignOutErrorScreen(error: error)
        }
    }
    
    func showSignOutErrorScreen(error: Error) {
        let navController = UINavigationController()
        let unableToLoginErrorScreen = ErrorPresenter
            .createUnableToLoginError(errorDescription: error.localizedDescription,
                                      analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                root.dismiss(animated: true)
            }
        navController.setViewControllers([unableToLoginErrorScreen], animated: false)
        unableToLoginErrorScreen.modalPresentationStyle = .overFullScreen
        root.present(navController, animated: true)
    }
}
