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
        app = .mock
        
        super.setUp()
    }
    
    override func tearDown() {
        sut = nil
        app = nil
        
        AppEnvironment.updateRemoteFlags(.mock)
        UserDefaults.standard.removeObject(forKey: "hasAccessedWalletBefore")
        
        super.tearDown()
    }
}

extension WalletAvailabilityServiceTests {
    func test_showWallet_flagEnabled_visibleToAll() {
        let mock = App(
            minimumVersion: Version(string: "1.0.0")!,
            allowAppUsage: true,
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: true],
            featureFlags: [:]
        )
        
        AppEnvironment.updateRemoteFlags(mock)

        XCTAssertTrue(sut.shouldShowFeature)
    }
    
    func test_hideWallet_flagEnabled_visibleToAll() {
        let mock = App(
            minimumVersion: Version(string: "1.0.0")!,
            allowAppUsage: true,
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: false],
            featureFlags: [:]
        )
        
        AppEnvironment.updateRemoteFlags(mock)
        
        XCTAssertFalse(sut.shouldShowFeature)
    }
    
    func test_showWallet_flagEnabled_ifExists_accessedBefore() {
        let mock = App(
            minimumVersion: Version(string: "1.0.0")!,
            allowAppUsage: true,
            releaseFlags: [
                FeatureFlagsName.enableWalletVisibleToAll.rawValue: false,
                FeatureFlagsName.enableWalletVisibleIfExists.rawValue: true
            ],
            featureFlags: [:]
        )
        
        AppEnvironment.updateRemoteFlags(mock)
        sut.hasAccessedBefore = true
        
        XCTAssertTrue(sut.shouldShowFeature)
    }
    
    func test_hideWallet_flagEnabled_ifExists_notAccessBefore() {
        let mock = App(
            minimumVersion: Version(string: "1.0.0")!,
            allowAppUsage: true,
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: false, FeatureFlagsName.enableWalletVisibleIfExists.rawValue: false],
            featureFlags: [:]
        )
        
        AppEnvironment.updateRemoteFlags(mock)
        
        XCTAssertFalse(sut.shouldShowFeature)
    }
    
    func test_hideWallet_flagEnabled_accessedBefore_notExists() {
        let mock = App(
            minimumVersion: Version(string: "1.0.0")!,
            allowAppUsage: true,
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: false],
            featureFlags: [:]
        )
        
        AppEnvironment.updateRemoteFlags(mock)
        sut.hasAccessedBefore = true
        
        XCTAssertFalse(sut.shouldShowFeature)
    }
    
    func test_showViaDeepLink_flagEnabled_visibleViaDeepLink() {
        let mock = App(
            minimumVersion: Version(string: "1.0.0")!,
            allowAppUsage: true,
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: true],
            featureFlags: [:]
        )
        
        AppEnvironment.updateRemoteFlags(mock)
        
        XCTAssertTrue(sut.shouldShowFeatureOnUniversalLink)
    }
    
    func test_hideViaDeepLink_flagEnabled_visibleToAll() {
        let mock = App(
            minimumVersion: Version(string: "1.0.0")!,
            allowAppUsage: true,
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: false],
            featureFlags: [:]
        )
        
        AppEnvironment.updateRemoteFlags(mock)
        
        XCTAssertFalse(sut.shouldShowFeatureOnUniversalLink)
    }
    
    func test_hideViaDeepLink_flagEnabled_visibleViaDeepLink() {
        let mock = App(
            minimumVersion: Version(string: "1.0.0")!,
            allowAppUsage: true,
            releaseFlags: [FeatureFlagsName.enableWalletVisibleToAll.rawValue: false, FeatureFlagsName.enableWalletVisibleViaDeepLink.rawValue: true],
            featureFlags: [:]
        )
        
        AppEnvironment.updateRemoteFlags(mock)
        
        XCTAssertTrue(sut.shouldShowFeatureOnUniversalLink)
    }
}

extension App {
    static var mock: App {
        .init(minimumVersion: Version(string: "1.0.0")!,
              allowAppUsage: true,
              releaseFlags: [:],
              featureFlags: [:])
    }
}
