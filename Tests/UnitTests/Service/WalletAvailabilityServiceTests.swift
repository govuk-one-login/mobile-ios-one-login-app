import Foundation
@testable import OneLogin
import XCTest

final class WalletAvailabilityServiceTests: XCTestCase {
    private var sut: MockWalletAvailabilityService!
    
    override func setUp() {
        sut = MockWalletAvailabilityService()
        
        super.setUp()
    }
    
    override func tearDown() {
        sut = nil
        UserDefaults.standard.removeObject(forKey: "hasAccessedWalletBefore")
        
        super.tearDown()
    }
}

extension WalletAvailabilityServiceTests {
    func test_showWallet_whenFlagEnabled() {
        sut.walletVisibleEnabled = false
        _ = sut.showWallet()
        XCTAssertFalse(sut.shouldShowWallet)
        
        sut.walletVisibleEnabled = true
        _ = sut.showWallet()
        XCTAssertTrue(sut.shouldShowWallet)
    }
    
    func test_showWallet_whenNoFlagsEnabled() {
        sut.hasAccessedWalletBefore = false
        sut.walletVisibleEnabled = false
        sut.deeplinkFlagEnabled = false
        
        XCTAssertFalse(sut.shouldShowWallet)

    }
    
    func test_hasAccessedWalletBefore_whenFlagEnabled() {
        XCTAssertFalse(sut.hasAccessedWalletBefore)
        
        sut.walletVisibleEnabled = true
        _ = sut.showWallet()
        
        XCTAssertTrue(sut.hasAccessedWalletBefore)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "hasAccessedWalletBefore"))
    }
    
    func test_hasAccessedWalletBefore_whenFlagNotEnabled() {
        sut.hasAccessedWalletBefore = true
        sut.walletVisibleEnabled = false
        sut.deeplinkFlagEnabled = false
        
        _ = sut.showWallet()
        
        XCTAssertTrue(sut.shouldShowWallet)
    }
}
