import Wallet

struct WalletSessionData: SessionBoundData {
    func clearSessionData() async throws {
        try await WalletSDK.deleteData()
    }
}

protocol WalletServiceProtocol {
    func isEmpty() async -> Bool
}

struct WalletSDKWrapper: WalletServiceProtocol {
    func isEmpty() async -> Bool {
        return await WalletSDK.isEmpty()
    }
}
