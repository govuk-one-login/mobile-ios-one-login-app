@testable import OneLogin
import Wallet
import XCTest

final class DummyLocalAuthServiceTests: XCTestCase {
    var localAuthentication: MockLocalAuthManager!
    var sut: DummyLocalAuthService!
    
    var didEnrol = false
    
    override func setUp() {
        super.setUp()
        
        localAuthentication = MockLocalAuthManager()
        sut = DummyLocalAuthService(localAuthentication: localAuthentication)
    }
    
    override func tearDown() {
        localAuthentication = nil
        sut = nil
        
        super.tearDown()
    }
}

enum WalletMockLocalAuthType: WalletLocalAuthType {
    case passcode
    case biometrics
    case none
}

extension DummyLocalAuthServiceTests {
    func test_ensureLocalAuthEnrolled() {
        XCTAssertTrue(sut.ensureLocalAuthEnrolled(WalletMockLocalAuthType.biometrics))
    }
    
    func test_enrolLocalAuth() {
        XCTAssertFalse(didEnrol)
        
        sut.enrolLocalAuth(
            WalletMockLocalAuthType.biometrics,
            completion: {
                self.didEnrol = true
            }
        )
        
        XCTAssertTrue(didEnrol)
    }
    
    func test_isEnrolled() {
        XCTAssertTrue(sut.isEnrolled(WalletMockLocalAuthType.biometrics))
    }
    
    func test_isEnrolledFalse() {
        XCTAssertTrue(sut.isEnrolled(WalletMockLocalAuthType.none))
    }
}
