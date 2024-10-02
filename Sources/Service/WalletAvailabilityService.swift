import Foundation
import Networking
import UIKit

protocol FeatureAvailabilityService: AnyObject {
    var hasAccessedBefore: Bool { get set }
    var shouldShowFeature: Bool { get }
}

protocol UniversalLinkFeatureAvailabilityService {
    var shouldShowFeatureOnUniversalLink: Bool { get }
}

typealias WalletFeatureAvailabilityService = FeatureAvailabilityService & UniversalLinkFeatureAvailabilityService & SessionBoundData

final class WalletAvailabilityService: WalletFeatureAvailabilityService {

    var hasAccessedBefore: Bool {
        get {
            UserDefaults.standard.bool(forKey: "hasAccessedWalletBefore")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "hasAccessedWalletBefore")
        }
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
    
    func delete() throws {
        hasAccessedBefore = false
    }
}
