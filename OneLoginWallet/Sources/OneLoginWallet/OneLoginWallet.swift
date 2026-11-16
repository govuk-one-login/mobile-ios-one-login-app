import Wallet
import WalletProtocol

public struct OneLoginWallet: WalletServiceProtocol {
    public static let instance = OneLoginWallet()
    
    /// Use ``instance`` to obtain a reference.
    public init() {
        // the `WalletSDKWrapper` is meant to represent an instance of the WalletSDK
        // when using its static function. Thus, using a `init` is moot.
    }
    
    public func delete() async throws(WalletStoreError) -> [WalletStoreError] {
        try await WalletSDK.delete()
    }
    
    public func isEmpty() async -> Bool {
        return await WalletSDK.isEmpty()
    }
}
