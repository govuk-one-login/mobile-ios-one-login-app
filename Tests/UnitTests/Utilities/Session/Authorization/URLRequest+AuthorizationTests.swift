@testable import OneLogin
import XCTest

final class URLRequestTests: XCTestCase {
    func test_tokenExchange() throws {
        let tokenRequest = URLRequest.tokenExchange(
            subjectToken: "tesSubjectToken",
            scope: "testScope"
        )

        let contentTypeHeader = tokenRequest.value(forHTTPHeaderField: "Content-Type")
        let httpMethod = tokenRequest.httpMethod
        let httpBody = try XCTUnwrap(tokenRequest.httpBody)
        let body = String(data: httpBody, encoding: .utf8)?.split(separator: "&")
        XCTAssertEqual(tokenRequest.url, URL(string: "https://token.build.account.gov.uk/token"))
        XCTAssertEqual(contentTypeHeader, "application/x-www-form-urlencoded")
        XCTAssertEqual(httpMethod, "POST")
        XCTAssertEqual(body?[0], "grant_type=urn:ietf:params:oauth:grant-type:token-exchange")
        XCTAssertEqual(body?[1], "scope=testScope")
        XCTAssertEqual(body?[2], "subject_token=tesSubjectToken")
        XCTAssertEqual(body?[3], "subject_token_type=urn:ietf:params:oauth:token-type:access_token")
    }
}
