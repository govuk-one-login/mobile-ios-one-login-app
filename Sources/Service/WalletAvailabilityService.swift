import Foundation
import Networking
import UIKit

protocol FeatureAvailabilityService {
    var hasAccessedBefore: Bool { get }
    var shouldShowFeature: Bool { get }
    func accessedFeature()
}

protocol UniversalLinkFeatureAvailabilityService {
    var shouldShowFeatureOnUniversalLink: Bool { get }
}

typealias WalletFeatureAvailabilityService = FeatureAvailabilityService & UniversalLinkFeatureAvailabilityService

class WalletAvailabilityService: WalletFeatureAvailabilityService {
    var hasAccessedBefore: Bool {
        UserDefaults.standard.bool(forKey: "hasAccessedWalletBefore")
    }
    
    var shouldShowFeature: Bool {
        guard AppEnvironment.walletVisibleToAll else {
            guard AppEnvironment.walletVisibleIfExists,
                  hasAccessedBefore else {
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
    
    func accessedFeature() {
        UserDefaults.standard.set(true, forKey: "hasAccessedWalletBefore")
    }
}
