import Wallet

struct WalletSessionData: SessionBoundData {
    func clearSessionData() async throws {
        try await WalletSDK.deleteData()
    }
}
