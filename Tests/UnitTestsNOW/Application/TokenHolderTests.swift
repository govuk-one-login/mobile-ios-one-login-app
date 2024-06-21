@testable import OneLoginNOW
import XCTest

final class TokenHolderTests: XCTestCase {
    var sut = TokenHolder()
}

extension TokenHolderTests {
    func test_bearerToken_returns() throws {
        sut.accessToken = "testAccessToken"
        XCTAssertEqual(try sut.bearerToken, "testAccessToken")
    }
    
    func test_bearerToken_errors() throws {
        do {
            _ = try sut.bearerToken
            XCTFail("Should throw TokenError error")
        } catch {
            XCTAssertTrue(error is TokenError)
        }
    }
    
    func test_tokenInDate() throws {
        sut.tokenResponse = try MockTokenResponse().getJSONData()
        XCTAssertTrue(sut.validAccessToken)
    }
    
    func test_tokenOutdated() throws {
        sut.tokenResponse = try MockTokenResponse().getJSONData(outdated: true)
        XCTAssertFalse(sut.validAccessToken)
    }
}
