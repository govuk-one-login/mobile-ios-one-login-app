import WalletProtocol
import WalletStore

public class MockWalletSDKWrapper: WalletServiceProtocol {
    typealias DeleteAsFunction = () async throws(WalletStoreError) -> [WalletStoreError]

    var deleteAsFunction: DeleteAsFunction

    var isEmpty: Bool = true

    init(deleteAsFunction: @escaping DeleteAsFunction = { return [] }) {
        self.deleteAsFunction = deleteAsFunction
    }

    public func delete() async throws(WalletStoreError) -> [WalletStoreError] {
        try await self.deleteAsFunction()
    }

    public func isEmpty() async -> Bool {
        return isEmpty
    }
}
