import Foundation
import Networking
import UIKit


public final class WalletAvailabilityService {
    var hasAccessedWalletBefore: Bool = false
    let defaults = UserDefaults.standard

    var showWallet: Bool {
        var shouldShowWallet = AppEnvironment.walletVisibleToAll
        var deeplinkAccepted = AppEnvironment.walletVisibleViaDeepLink
        
        if shouldShowWallet == false {
            guard deeplinkAccepted == true else {
                return UserDefaults.standard.bool(forKey: "hasAccessedWalletBefore")
            }
            shouldShowWallet = true
        }
        return shouldShowWallet
    }
    
    func hasAccessedPreviously() {
        hasAccessedWalletBefore = true
        defaults.set(hasAccessedWalletBefore, forKey: "hasAccessedWalletBefore")
    }
}
