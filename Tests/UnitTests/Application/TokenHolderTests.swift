@testable import OneLogin
import XCTest

final class TokenHolderTests: XCTestCase {
    private var sut = TokenHolder()
}

extension TokenHolderTests {
    func test_bearerToken_returns() throws {
        let tokenResponse = try MockTokenResponse().getJSONData()
        sut.update(tokens: tokenResponse)
        XCTAssertEqual(try sut.bearerToken, "accessTokenResponse")
    }
    
    func test_bearerToken_errors() throws {
        do {
            _ = try sut.bearerToken
            XCTFail("Should throw TokenError error")
        } catch {
            XCTAssertTrue(error is TokenError)
        }
    }
}
