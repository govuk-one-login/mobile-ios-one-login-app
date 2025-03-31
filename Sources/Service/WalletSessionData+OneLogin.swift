import Wallet

struct WalletSessionData: SessionBoundData {
    func delete() async throws {
        try await WalletSDK.deleteData()
    }
}
