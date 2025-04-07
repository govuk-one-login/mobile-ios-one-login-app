@testable import OneLogin
import XCTest

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

extension DummyLocalAuthServiceTests {
    func test_faceID() {
        localAuthentication.type = .faceID
        sut.evaluateLocalAuth(navigationController: UINavigationController()) { authType in
            XCTAssertEqual(authType, .face)
        }
    }
    
    func test_touchID() {
        localAuthentication.type = .touchID
        sut.evaluateLocalAuth(navigationController: UINavigationController()) { authType in
            XCTAssertEqual(authType, .touch)
        }
    }
    
    func test_passcode() {
        localAuthentication.type = .passcode
        sut.evaluateLocalAuth(navigationController: UINavigationController()) { authType in
            XCTAssertEqual(authType, .passcode)
        }
    }
    
    func test_none() {
        localAuthentication.type = .none
        sut.evaluateLocalAuth(navigationController: UINavigationController()) { authType in
            XCTAssertEqual(authType, .none)
        }
    }
}
