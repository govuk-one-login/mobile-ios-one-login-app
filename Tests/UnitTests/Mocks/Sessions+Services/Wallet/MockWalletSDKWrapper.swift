@testable import OneLogin
import Wallet
import WalletStore
import WalletProtocol

// TODO: DCMAW-23968 Delete this mock and use mock from package MockWallet
final class MockWalletSDKWrapper: WalletServiceProtocol {
    typealias DeleteAsFunction = () async throws(WalletStoreError) -> [WalletStoreError]

    var deleteAsFunction: DeleteAsFunction

    var isEmpty: Bool = true

    init(deleteAsFunction: @escaping DeleteAsFunction = { return [] }) {
        self.deleteAsFunction = deleteAsFunction
    }

    func delete() async throws(WalletStoreError) -> [WalletStoreError] {
        try await self.deleteAsFunction()
    }

    func isEmpty() async -> Bool {
        return isEmpty
    }
}
