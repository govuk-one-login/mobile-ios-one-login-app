import Wallet

struct WalletSessionData: SessionBoundData {
    func delete() throws {
        try WalletSDK.deleteData()
    }
}
