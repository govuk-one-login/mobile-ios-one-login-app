import OneLoginWallet
import Wallet
import WalletProtocol

extension OneLoginWallet {
    static func make() -> WalletServiceProtocol {
        return OneLoginWallet()
    }
}
