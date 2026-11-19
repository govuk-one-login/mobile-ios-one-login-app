import OneLoginWallet
import Wallet
import WalletInterface
import WalletProtocol

extension OneLoginWallet {
    static func make() -> WalletServiceProtocol {
        return OneLoginWallet()
    }
}

extension WalletConfigV4 {
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
            trustedReaderCertificates: trustedReaderCertificates()
        )
        #else
        return WalletConfigV4(
            environment: environment,
            clientID: AppEnvironment.stsClientID,
            walletStoreID: walletStoreID,
            trustedReaderCertificates: []
        )
        #endif
    }
}
