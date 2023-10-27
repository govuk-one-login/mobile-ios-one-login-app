import Foundation
@testable import OneLogin
import XCTest

final class AppEnvironmentTests: XCTestCase {
    var sut: AppEnvironment!
    
    override func setUp() {
        super.setUp()
        
        sut = AppEnvironment()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
}

extension AppEnvironmentTests {
    func test_defaultEnvironment_retrieveFromPlist() throws {
        XCTAssertEqual(sut.string(for: .authorizeEndPoint), "oidc.integration.account.gov.uk")
        XCTAssertEqual(sut.string(for: .tokenEndpoint), "test.com")
        XCTAssertEqual(sut.string(for: .clientId), "sdJChz1oGajIz0O0tdPdh0CA2zW")
        XCTAssertEqual(sut.string(for: .redirectURL), "https://mobile.staging.account.gov.uk/redirect")
    }
}
