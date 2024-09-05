import Foundation
import Networking
import UIKit

protocol FeatureAvailabilityService {
    var shouldShowFeature: Bool { get }
    func hasAccessedPreviously()
}

protocol UniversalLinkFeatureAvailabilityService {
    var shouldShowFeatureOnUniversalLink: Bool { get }
}

typealias WalletFeatureAvailabilityService = FeatureAvailabilityService & UniversalLinkFeatureAvailabilityService

class WalletAvailabilityService: WalletFeatureAvailabilityService {
    var shouldShowFeature: Bool {
        guard AppEnvironment.walletVisibleToAll else {
            guard AppEnvironment.walletVisibleIfExists,
                  UserDefaults.standard.bool(forKey: "hasAccessedWalletBefore") else {
                return false
            }
            return true
        }
        return true
    }
    
    var shouldShowFeatureOnUniversalLink: Bool {
        guard AppEnvironment.walletVisibleToAll else {
            guard AppEnvironment.walletVisibleViaDeepLink else {
                return false
            }
            return true
        }
        return true
    }
    
    func hasAccessedPreviously() {
        UserDefaults.standard.set(true, forKey: "hasAccessedWalletBefore")
    }
}
