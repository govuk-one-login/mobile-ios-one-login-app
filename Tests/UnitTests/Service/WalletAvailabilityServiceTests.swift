import Foundation
import MobilePlatformServices
import Networking
@testable import OneLogin
import XCTest

final class WalletAvailabilityServiceTests: XCTestCase {
    override func tearDown() {
        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [:]
        )
        UserDefaults.standard.removeObject(forKey: OLString.hasAccessedWalletBefore)
        
        super.tearDown()
    }
}

extension WalletAvailabilityServiceTests {
    func test_showWallet_flagEnabled_visibleToAll() {
        AppEnvironment.updateFlags(
            releaseFlags: [
                FeatureFlagsName.enableWalletVisibleToAll.rawValue: true
            ],
            featureFlags: [:]
        )

        XCTAssertTrue(WalletAvailabilityService.shouldShowFeature)
    }
    
    func test_showWallet_flagEnabled_ifExists_accessedBefore() {
        AppEnvironment.updateFlags(
            releaseFlags: [
                FeatureFlagsName.enableWalletVisibleToAll.rawValue: false,
                FeatureFlagsName.enableWalletVisibleIfExists.rawValue: true
            ],
            featureFlags: [:]
        )
        WalletAvailabilityService.hasAccessedBefore = true
        
        XCTAssertTrue(WalletAvailabilityService.shouldShowFeature)
    }
    
    func test_showWallet_flagsDisabled_notAccessedBefore() {
        AppEnvironment.updateFlags(
            releaseFlags: [
                FeatureFlagsName.enableWalletVisibleToAll.rawValue: false,
                FeatureFlagsName.enableWalletVisibleIfExists.rawValue: false
            ],
            featureFlags: [:]
        )
        WalletAvailabilityService.hasAccessedBefore = false
        
        XCTAssertFalse(WalletAvailabilityService.shouldShowFeature)
    }
    
    func test_showWallet_flagDisabled_ifExists_accessedBefore() {
        AppEnvironment.updateFlags(
            releaseFlags: [
                FeatureFlagsName.enableWalletVisibleToAll.rawValue: false,
                FeatureFlagsName.enableWalletVisibleIfExists.rawValue: false
            ],
            featureFlags: [:]
        )
        WalletAvailabilityService.hasAccessedBefore = true
        
        XCTAssertFalse(WalletAvailabilityService.shouldShowFeature)
    }
    
    func test_showWallet_flagEnabled_ifExists_notAccessedBefore() {
        AppEnvironment.updateFlags(
            releaseFlags: [
                FeatureFlagsName.enableWalletVisibleToAll.rawValue: false,
                FeatureFlagsName.enableWalletVisibleIfExists.rawValue: true
            ],
            featureFlags: [:]
        )
        WalletAvailabilityService.hasAccessedBefore = false
        
        XCTAssertFalse(WalletAvailabilityService.shouldShowFeature)
    }
    
    func test_showViaDeepLink_flagEnabled_visibleToAll() {
        AppEnvironment.updateFlags(
            releaseFlags: [
                FeatureFlagsName.enableWalletVisibleToAll.rawValue: true
            ],
            featureFlags: [:]
        )
        
        XCTAssertTrue(WalletAvailabilityService.shouldShowFeatureOnUniversalLink)
    }
    
    func test_showViaDeepLink_flagEnabled_visibleViaDeepLink() {
        AppEnvironment.updateFlags(
            releaseFlags: [
                FeatureFlagsName.enableWalletVisibleToAll.rawValue: false,
                FeatureFlagsName.enableWalletVisibleViaDeepLink.rawValue: true

            ],
            featureFlags: [:]
        )
        
        XCTAssertTrue(WalletAvailabilityService.shouldShowFeatureOnUniversalLink)
    }
    
    func test_showViaDeepLink_flagsDisabled() {
        AppEnvironment.updateFlags(
            releaseFlags: [
                FeatureFlagsName.enableWalletVisibleToAll.rawValue: false,
                FeatureFlagsName.enableWalletVisibleViaDeepLink.rawValue: false
            ],
            featureFlags: [:]
        )
        
        XCTAssertFalse(WalletAvailabilityService.shouldShowFeatureOnUniversalLink)
    }
}
