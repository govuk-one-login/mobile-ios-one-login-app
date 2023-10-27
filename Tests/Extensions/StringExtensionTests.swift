@testable import OneLogin
import XCTest

final class StringExtensionTests: XCTestCase {
    func test_oneLoginStringExtensions() throws {
        XCTAssertEqual(String.oneLoginClientID, "sdJChz1oGajIz0O0tdPdh0CA2zW")
        XCTAssertEqual(String.oneLoginRedirect, "https://mobile.staging.account.gov.uk/redirect")
    }
}
