@testable import OneLogin
import XCTest

class MockWalletAvailabilityService: WalletFeatureAvailabilityService {
    var hasAccessedPreviously = false
    var shouldShowFeature = false
    var shouldShowFeatureOnUniversalLink = false
    
    func featureAccessed() { }
}
