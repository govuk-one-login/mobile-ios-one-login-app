@testable import OneLogin
import Wallet

struct MockWalletSDKWrapper: WalletServiceProtocol {
    var isEmpty: Bool = true
    
    func isEmpty() async -> Bool {
        return isEmpty
    }
}
