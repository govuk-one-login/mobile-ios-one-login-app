import Foundation
import Networking
import UIKit


public final class WalletAvailabilityService {
    let defaults = UserDefaults.standard
    
    var walletVisibleToAll = AppEnvironment.walletVisibleToAll
    var deeplinkAccepted = AppEnvironment.walletVisibleViaDeepLink
    
    func showWallet() -> Bool {
        if !walletVisibleToAll {
            guard deeplinkAccepted else {
                return UserDefaults.standard.bool(forKey: "hasAccessedWalletBefore")
            }
        }
        return true
    }
    
    func hasAccessedPreviously() {
        defaults.set(true, forKey: "hasAccessedWalletBefore")
    }
}
