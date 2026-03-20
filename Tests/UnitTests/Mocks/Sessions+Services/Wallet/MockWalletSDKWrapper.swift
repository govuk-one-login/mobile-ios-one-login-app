@testable import OneLogin
import Wallet

final class MockWalletSDKWrapper: WalletServiceProtocol {
    var isEmpty: Bool = true
    
    func isEmpty() async -> Bool {
        return isEmpty
    }
}
