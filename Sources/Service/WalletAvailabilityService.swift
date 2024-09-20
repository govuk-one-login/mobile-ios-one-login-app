import Foundation
import Networking
import UIKit

protocol FeatureAvailabilityService {
    var hassAccessedPreviously: Bool { get }
    var shouldShowFeature: Bool { get }
    func featureAccessed()
}

protocol UniversalLinkFeatureAvailabilityService {
    var shouldShowFeatureOnUniversalLink: Bool { get }
}

typealias WalletFeatureAvailabilityService = FeatureAvailabilityService & UniversalLinkFeatureAvailabilityService

struct WalletAvailabilityService: WalletFeatureAvailabilityService {
    var hassAccessedPreviously: Bool {
        UserDefaults.standard.bool(forKey: .hasAccessedWalletPreviously)
    }
    
    var shouldShowFeature: Bool {
        guard AppEnvironment.walletVisibleToAll else {
            guard AppEnvironment.walletVisibleIfExists,
                  UserDefaults.standard.bool(forKey: .hasAccessedWalletPreviously) else {
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
    
    func featureAccessed() {
        UserDefaults.standard.set(true, forKey: .hasAccessedWalletPreviously)
    }
}
