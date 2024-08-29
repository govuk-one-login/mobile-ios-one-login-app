@testable import OneLogin
import XCTest

final class DummyLocalAuthServiceTests: XCTestCase {
    var mockLAContext: MockLAContext!
    var sut: DummyLocalAuthService!
    
    override func setUp() {
        super.setUp()
        
        mockLAContext = MockLAContext()
        sut = DummyLocalAuthService(context: mockLAContext)
    }
    
    override func tearDown() {
        mockLAContext = nil
        sut = nil
        
        super.tearDown()
    }
}

extension DummyLocalAuthServiceTests {
    func test_faceID() {
        mockLAContext.biometryType = .faceID
        mockLAContext.localAuthIsEnabledOnTheDevice = true
        sut.evaluateLocalAuth(navigationController: UINavigationController()) { authType in
            XCTAssertEqual(authType, .face)
        }
    }
    
    func test_touchID() {
        mockLAContext.biometryType = .touchID
        mockLAContext.localAuthIsEnabledOnTheDevice = true
        sut.evaluateLocalAuth(navigationController: UINavigationController()) { authType in
            XCTAssertEqual(authType, .touch)
        }
    }
    
    func test_none() {
        mockLAContext.localAuthIsEnabledOnTheDevice = false
        sut.evaluateLocalAuth(navigationController: UINavigationController()) { authType in
            XCTAssertEqual(authType, .none)
        }
    }
    
    func test_passcode() {
        mockLAContext.biometryType = .none
        mockLAContext.localAuthIsEnabledOnTheDevice = true
        sut.evaluateLocalAuth(navigationController: UINavigationController()) { authType in
            XCTAssertEqual(authType, .passcode)
        }
    }
}
