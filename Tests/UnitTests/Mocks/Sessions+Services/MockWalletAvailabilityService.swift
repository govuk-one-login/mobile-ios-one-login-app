import Foundation
import Networking

@testable import OneLogin

final class MockWalletAvailabilityService {
    var hasAccessedWalletBefore: Bool = false
    var shouldShowWallet: Bool = false
    
    var walletVisibleEnabled: Bool = false
    var deeplinkFlagEnabled: Bool = false
    
    func showWallet() -> Bool {
        if walletVisibleEnabled {
            shouldShowWallet = true
            hasAccessedWalletBefore = true
        } else {
            if deeplinkFlagEnabled {
                shouldShowWallet = true
                hasAccessedWalletBefore = true
            } else {
                if hasAccessedWalletBefore {
                    shouldShowWallet = true
                }
            }
        }
        hasAccessedPreviously()
        return shouldShowWallet
    }
    
    func hasAccessedPreviously() {
        guard hasAccessedWalletBefore else {
            return
        }
        UserDefaults.standard.set(hasAccessedWalletBefore, forKey: "hasAccessedWalletBefore")
    }
}
