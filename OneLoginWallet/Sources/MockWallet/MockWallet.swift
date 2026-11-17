import WalletProtocol
import WalletStore

public class MockWallet: WalletServiceProtocol {
    public typealias DeleteAsFunction = () async throws(WalletStoreError) -> [WalletStoreError]

    public var deleteAsFunction: DeleteAsFunction

    public var isEmpty: Bool = true

    public init(deleteAsFunction: @escaping DeleteAsFunction = { return [] }) {
        self.deleteAsFunction = deleteAsFunction
    }

    public func delete() async throws(WalletStoreError) -> [WalletStoreError] {
        try await self.deleteAsFunction()
    }

    public func isEmpty() async -> Bool {
        return isEmpty
    }
}
