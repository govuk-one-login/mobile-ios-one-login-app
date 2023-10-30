@testable import OneLogin
import XCTest

final class AppEnvironmentTests: XCTestCase {
    func test_defaultEnvironment_retrieveFromPlist() throws {
        let sut = AppEnvironment.self
        XCTAssertEqual(sut.string(for: .authorizeEndPoint), "oidc.integration.account.gov.uk")
        XCTAssertEqual(sut.value(for: .authorizeEndPoint), "oidc.integration.account.gov.uk")
        XCTAssertEqual(sut.string(for: .tokenEndpoint), "test.com")
        XCTAssertEqual(sut.value(for: .tokenEndpoint), "test.com")
        XCTAssertEqual(sut.string(for: .clientId), "sdJChz1oGajIz0O0tdPdh0CA2zW")
        XCTAssertEqual(sut.value(for: .clientId), "sdJChz1oGajIz0O0tdPdh0CA2zW")
        XCTAssertEqual(sut.string(for: .redirectURL), "https://mobile.staging.account.gov.uk/redirect")
        XCTAssertEqual(sut.value(for: .redirectURL), "https://mobile.staging.account.gov.uk/redirect")
    }
}
