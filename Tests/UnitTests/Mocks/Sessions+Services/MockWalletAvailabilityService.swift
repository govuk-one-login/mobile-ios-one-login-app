@testable import OneLogin
import XCTest

class MockWalletAvailabilityService: WalletFeatureAvailabilityService {
    var shouldShowFeature = false
    var shouldShowFeatureOnUniversalLink = false
    
    func featureAccessed() { }
}
