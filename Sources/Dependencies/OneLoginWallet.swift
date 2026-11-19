import OneLoginWallet
import Wallet
import WalletInterface
import WalletProtocol

extension OneLoginWallet {
    public enum FeatureFlag: String, CaseIterable {
        case sharing
    }

    static func make() -> WalletServiceProtocol {
        return OneLoginWallet()
    }
}

extension AppEnvironment {
    
    static func walletFeatureFlags() -> Set<WalletFeatureFlag> {
        let enabledFlags = Set(featureFlags)

        return Set(OneLoginWallet.FeatureFlag.allCases).map { featureFlag in
            let enables = enabledFlags.contains(flag)

            switch featureFlag {
            case .sharing:
                return .sharing(enabled)
            }
        }
    }
}

extension WalletConfigV4 {

    /// Returns a configuration to be used by the ``WalletSDK``.
    ///
    /// - Parameters:
    ///     - environment: the environment under which wallet is running.
    ///     - clientID: the client ID; *default* ``AppEnvironment.stsClientID``
    ///     - walletStoreID: the wallet store id as returned by ``PersistentSessionManager/walletStoreID``
    ///     - trustedReaderCertificates: **lazy** an array of ``TrustedCertificate``. Since this is only required when sharing is enabled and **opt-in**, it is lazily computed to avoid any performance cost incurred but more importantly to avoid any side effects and/or unwanted behaviour. See **Note**.
    /// - SeeAlso: ``[TrustedCertificate].load()`` on loading the certificates bundled within the application
    /// - Note: This function uses conditional compilation to "enable sharing" in case the `SHARING_ENABLED` is present. Enabling sharing is **opt-in**. In which case, the certificates will be used in the returned wallet configuration.
    /// - SeeAlso: https://developer.apple.com/documentation/xcode/build-settings-reference#Active-Compilation-Conditions
    static func make(
        environment: WalletEnvironment,
        clientID: String = AppEnvironment.stsClientID,
        walletStoreID: String,
        trustedReaderCertificates: @autoclosure () -> [any TrustedCertificate]
    ) -> WalletConfigV4 {
        #if SHARING_ENABLED

        return WalletConfigV4(
            environment: environment,
            clientID: clientID,
            walletStoreID: walletStoreID,
            trustedReaderCertificates: trustedReaderCertificates(),
            featureFlags: AppEnvironment.walletFeatureFlags()
        )
        #else
        return WalletConfigV4(
            environment: environment,
            clientID: clientID,
            walletStoreID: walletStoreID,
            trustedReaderCertificates: []
        )
        #endif
    }
}
