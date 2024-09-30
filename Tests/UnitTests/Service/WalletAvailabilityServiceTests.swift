import Foundation
@testable import OneLogin
import XCTest

final class WalletAvailabilityServiceTests: XCTestCase {
    private var sut: WalletAvailabilityService!
    
    override func setUp() {
        sut = WalletAvailabilityService()
        
        super.setUp()
    }
    
    override func tearDown() {
        sut = nil
        
        AppEnvironment.updateReleaseFlags([:])
        UserDefaults.standard.removeObject(forKey: "hasAccessedWalletBefore")
        
        super.tearDown()
    }
}

extension WalletAvailabilityServiceTests {
    func test_showWallet_flagEnabled_visibleToAll() {
        AppEnvironment.updateReleaseFlags([
            FeatureFlags.enableWalletVisibleToAll.rawValue: true
        ])
        
        XCTAssertTrue(sut.shouldShowFeature)
    }
    
    func test_hideWallet_flagEnabled_visibleToAll() {
        AppEnvironment.updateReleaseFlags([
            FeatureFlags.enableWalletVisibleToAll.rawValue: false
        ])
        
        XCTAssertFalse(sut.shouldShowFeature)
    }
    
    func test_showWallet_flagEnabled_ifExists_accessedBefore() {
        AppEnvironment.updateReleaseFlags([
            FeatureFlags.enableWalletVisibleToAll.rawValue: false,
            FeatureFlags.enableWalletVisibleIfExists.rawValue: true
        ])
        sut.accessedFeature()
        
        XCTAssertTrue(sut.shouldShowFeature)
    }
    
    func test_hideWallet_flagEnabled_ifExists_notAccessBefore() {
        AppEnvironment.updateReleaseFlags([
            FeatureFlags.enableWalletVisibleToAll.rawValue: false,
            FeatureFlags.enableWalletVisibleIfExists.rawValue: false
        ])
        
        XCTAssertFalse(sut.shouldShowFeature)
    }
    
    func test_hideWallet_flagEnabled_accessedBefore_notExists() {
        AppEnvironment.updateReleaseFlags([
            FeatureFlags.enableWalletVisibleToAll.rawValue: false
        ])
        sut.accessedFeature()
        
        XCTAssertFalse(sut.shouldShowFeature)
    }
    
    func test_showViaDeepLink_flagEnabled_visibleViaDeepLink() {
        AppEnvironment.updateReleaseFlags([
            FeatureFlags.enableWalletVisibleToAll.rawValue: true
        ])
        
        XCTAssertTrue(sut.shouldShowFeatureOnUniversalLink)
    }
    
    func test_hideViaDeepLink_flagEnabled_visibleToAll() {
        AppEnvironment.updateReleaseFlags([
            FeatureFlags.enableWalletVisibleToAll.rawValue: false
        ])
        
        XCTAssertFalse(sut.shouldShowFeatureOnUniversalLink)
    }
    
    func test_hideViaDeepLink_flagEnabled_visibleViaDeepLink() {
        AppEnvironment.updateReleaseFlags([
            FeatureFlags.enableWalletVisibleToAll.rawValue: false,
            FeatureFlags.enableWalletVisibleViaDeepLink.rawValue: true
        ])
        
        XCTAssertTrue(sut.shouldShowFeatureOnUniversalLink)
    }
}
