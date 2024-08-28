@testable import OneLogin
import XCTest

final class LocalAuthManagerTests: XCTestCase {
    var mockLAContext: MockLAContext!
    var sut: LocalAuthManager!
    
    override func setUp() {
        super.setUp()
        
        mockLAContext = MockLAContext()
        sut = LocalAuthManager(localAuthContext: mockLAContext)
    }
    
    override func tearDown() {
        mockLAContext = nil
        sut = nil
        
        super.tearDown()
    }
}

extension LocalAuthManagerTests {
    func test_biometryType() {
        XCTAssertEqual(sut.biometryType, .touchID)
    }
    
    func test_canUseLocalAuth() {
        XCTAssertFalse(sut.canUseLocalAuth(type: .deviceOwnerAuthentication))
    }
    
    func test_enrolLocalAuth() async throws {
        try await sut.enrolLocalAuth(reason: "")
        XCTAssertEqual(mockLAContext.localizedFallbackTitle, "Enter passcode")
        XCTAssertEqual(mockLAContext.localizedCancelTitle, "Cancel")
    }
}
