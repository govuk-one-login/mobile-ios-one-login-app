import WalletStore

public protocol WalletServiceProtocol {
    func delete() async throws(WalletStoreError) -> [WalletStoreError]
    func isEmpty() async -> Bool
}
