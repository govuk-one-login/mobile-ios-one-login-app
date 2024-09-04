import Coordination
import GDSCommon
import LocalAuthentication
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
    private var analyticsCenter: AnalyticsCentral
    private let sessionManager: SessionManager
    private let walletSDK = WalletSDK()

    private lazy var networkClient = {
        NetworkClient(authenticationProvider: sessionManager.tokenProvider)
    }()

    init(window: UIWindow,
         analyticsCenter: AnalyticsCentral,
         sessionManager: SessionManager) {
        self.window = window
        self.analyticsCenter = analyticsCenter
        self.sessionManager = sessionManager
    }
    
    func start() {
        root.tabBarItem = UITabBarItem(title: GDSLocalisedString(stringLiteral: "app_walletTitle").value,
                                       image: UIImage(systemName: "wallet.pass"),
                                       tag: 1)
        walletSDK.start(in: window,
                        with: root,
                        networkClient: networkClient,
                        analyticsService: analyticsCenter.analyticsService,
                        localAuthService: DummyLocalAuthService(),
                        // TEMPORARY FIX
                        credentialIssuer:
                            "https://example-credential-issuer.mobile.build.account.gov.uk")
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(clearWallet),
                         name: Notification.Name(.clearWallet),
                         object: nil)
    }
    
    func handleUniversalLink(_ url: URL) {
        walletSDK.deeplink(with: url.absoluteString)
    }
    
    func deleteWalletData() throws {
        #if DEBUG
        if AppEnvironment.clearWalletErrorEnabled {
            throw TokenError.expired
        }
        #endif
        try walletSDK.deleteWalletData()
    }
    
    @objc private func clearWallet() {
        do {
            try deleteWalletData()
            sessionManager.clearAllSessionData()
            analyticsCenter.analyticsPreferenceStore.hasAcceptedAnalytics = nil
            let dataDeletionWarningScreen = ErrorPresenter
                .createDataDeletionWarning(analyticsService: analyticsCenter.analyticsService) { [unowned self] in
                    window.rootViewController?.presentedViewController?.dismiss(animated: true) {
                        NotificationCenter.default.post(name: Notification.Name(.returnToIntroScreen), object: nil)
                    }
                }
            dataDeletionWarningScreen.modalPresentationStyle = .overFullScreen
            window.rootViewController?.presentedViewController?.present(dataDeletionWarningScreen, animated: true)
        } catch {
            let unableToLoginErrorScreen = ErrorPresenter
                .createUnableToLoginError(errorDescription: error.localizedDescription,
                                          analyticsService: analyticsCenter.analyticsService) {
                    exit(0)
                }
            unableToLoginErrorScreen.modalPresentationStyle = .overFullScreen
            window.rootViewController?.presentedViewController?.present(unableToLoginErrorScreen, animated: true)
        }
    }
}
