@testable import OneLogin
import XCTest
import Wallet

final class DummyLocalAuthServiceTests: XCTestCase {
    var localAuthentication: MockLocalAuthManager!
    var sut: DummyLocalAuthService!
    
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
    
    func test_isEnrolled() {
        XCTAssertTrue(sut.isEnrolled(WalletMockLocalAuthType.biometrics))
    }
}
