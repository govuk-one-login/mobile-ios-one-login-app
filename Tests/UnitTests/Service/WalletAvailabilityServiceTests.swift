import Foundation
import MobilePlatformServices
import Networking
@testable import OneLogin
import XCTest

final class WalletAvailabilityServiceTests: XCTestCase {
    private var sut: WalletAvailabilityService!
    private var app: App!
    
    override func setUp() {
        sut = WalletAvailabilityService()
        
        super.setUp()
    }
    
    override func tearDown() {
        sut = nil
        app = nil
        
        AppEnvironment.updateFlags(
            releaseFlags: [:],
            featureFlags: [:]
        )
        UserDefaults.standard.removeObject(forKey: "hasAccessedWalletBefore")
        
        super.tearDown()
    }
}

extension WalletAvailabilityServiceTests {
    func test_showWallet_flagEnabled_visibleToAll() {
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: true],
            featureFlags: [:]
        )

        XCTAssertTrue(sut.shouldShowFeature)
    }
    
    func test_hideWallet_flagEnabled_visibleToAll() {
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: false],
            featureFlags: [:]
        )
        
        XCTAssertFalse(sut.shouldShowFeature)
    }
    
    func test_showWallet_flagEnabled_ifExists_accessedBefore() {
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: false,
                           FeatureFlagsName.enableWalletVisibleIfExists.rawValue: true],
            featureFlags: [:]
        )
        sut.hasAccessedBefore = true
        
        XCTAssertTrue(sut.shouldShowFeature)
    }
    
    func test_hideWallet_flagEnabled_ifExists_notAccessBefore() {
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: false,
                           FeatureFlagsName.enableWalletVisibleIfExists.rawValue: false],
            featureFlags: [:]
        )
        
        XCTAssertFalse(sut.shouldShowFeature)
    }
    
    func test_hideWallet_flagEnabled_accessedBefore_notExists() {
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: false],
            featureFlags: [:]
        )
        sut.hasAccessedBefore = true
        
        XCTAssertFalse(sut.shouldShowFeature)
    }
    
    func test_showViaDeepLink_flagEnabled_visibleViaDeepLink() {
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: true],
            featureFlags: [:]
        )
        
        XCTAssertTrue(sut.shouldShowFeatureOnUniversalLink)
    }
    
    func test_hideViaDeepLink_flagEnabled_visibleToAll() {
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: false],
            featureFlags: [:]
        )
        
        XCTAssertFalse(sut.shouldShowFeatureOnUniversalLink)
    }
    
    func test_hideViaDeepLink_flagEnabled_visibleViaDeepLink() {
        AppEnvironment.updateFlags(
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: false,
                           FeatureFlagsName.enableWalletVisibleViaDeepLink.rawValue: true],
            featureFlags: [:]
        )
        
        XCTAssertTrue(sut.shouldShowFeatureOnUniversalLink)
    }
}
