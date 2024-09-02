import Foundation
@testable import OneLogin
import XCTest

final class WalletAvailabilityServiceTests: XCTestCase {
    private var sut: WalletAvailabilityService!
    
    override func setUp() {
        sut = WalletAvailabilityService()
        UserDefaults.standard.set(false, forKey: "hasAccessedWalletBefore")
        
        super.setUp()
    }
    
    override func tearDown() {
        sut = nil
        
        UserDefaults.standard.removeObject(forKey: FeatureFlags.enableWalletVisibleToAll.rawValue)
        UserDefaults.standard.removeObject(forKey: "hasAccessedWalletBefore")
        
        super.tearDown()
    }
}

extension WalletAvailabilityServiceTests {
    func test_showWallet_whenFlagEnabled() {
        sut.walletVisibleToAll = false
        XCTAssertFalse(sut.showWallet())
        
        sut.walletVisibleToAll = true
        XCTAssertTrue(sut.showWallet())
    }
    
    func test_showWallet_whenDeeplinkFlagEnabled() {
        sut.deeplinkAccepted = false
        XCTAssertFalse(sut.showWallet())
        
        sut.deeplinkAccepted = true
        XCTAssertTrue(sut.showWallet())
    }

    func test_hasAccessedWalletBefore() {
        XCTAssertFalse(sut.defaults.bool(forKey: "hasAccessedWalletBefore"))

        sut.hasAccessedPreviously()

        XCTAssertTrue(sut.defaults.bool(forKey: "hasAccessedWalletBefore"))
    }

    func test_hasAccessedWalletBefore_whenFlagNotEnabled() {
        sut.defaults.set(true, forKey: "hasAccessedWalletBefore")
        sut.walletVisibleToAll = false
        sut.deeplinkAccepted = false

        _ = sut.showWallet()

        XCTAssertTrue(sut.showWallet())
    }
}
