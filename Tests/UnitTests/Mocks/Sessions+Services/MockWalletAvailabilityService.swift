@testable import OneLogin
import XCTest

class MockWalletAvailabilityService: WalletFeatureAvailabilityService {
    var hasAccessedBefore = false
    var shouldShowFeature = false
    var shouldShowFeatureOnUniversalLink = false
    
    func accessedFeature() {
        hasAccessedBefore = true
    }
}
