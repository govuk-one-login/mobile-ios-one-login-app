import Wallet

struct WalletSessionData: SessionBoundData {
    func delete() throws {
        Task {
            try await WalletSDK.deleteData()
        }
    }
}
