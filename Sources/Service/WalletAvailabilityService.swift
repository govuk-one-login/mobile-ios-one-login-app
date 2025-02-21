import Foundation
import Networking
import UIKit

protocol FeatureAvailabilityService: AnyObject {
    static var hasAccessedBefore: Bool { get set }
    static var shouldShowFeature: Bool { get }
}

protocol UniversalLinkFeatureAvailabilityService {
    static var shouldShowFeatureOnUniversalLink: Bool { get }
}

typealias WalletFeatureAvailabilityService = FeatureAvailabilityService & UniversalLinkFeatureAvailabilityService & SessionBoundData

final class WalletAvailabilityService: WalletFeatureAvailabilityService {
    static var hasAccessedBefore: Bool {
        get {
            UserDefaults.standard.bool(forKey: OLString.hasAccessedWalletBefore)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: OLString.hasAccessedWalletBefore)
        }
    }
    
    static var shouldShowFeature: Bool {
        guard AppEnvironment.walletVisibleToAll else {
            guard AppEnvironment.walletVisibleIfExists,
                  hasAccessedBefore else {
                return false
            }
            return true
        }
        return true
    }
    
    static var shouldShowFeatureOnUniversalLink: Bool {
        guard AppEnvironment.walletVisibleToAll else {
            guard AppEnvironment.walletVisibleViaDeepLink else {
                return false
            }
            return true
        }
        return true
    }
    
    func delete() throws {
        Self.hasAccessedBefore = false
    }
}
