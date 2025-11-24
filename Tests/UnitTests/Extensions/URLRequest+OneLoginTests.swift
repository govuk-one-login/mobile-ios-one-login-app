@testable import OneLogin
import XCTest

final class URLRequestTests: XCTestCase {
    func test_refreshTokenExchange() async throws {
        let tokenRequest = try await URLRequest.refreshTokenExchange(
            token: "testRefreshToken",
            appIntegrityProvider: MockAppIntegrityProvider()
        )

        let contentTypeHeader = tokenRequest.value(forHTTPHeaderField: "Content-Type")
        let appIntegrityHeaders = tokenRequest.value(forHTTPHeaderField: "testAsserion")
        let httpMethod = tokenRequest.httpMethod
        let httpBody = try XCTUnwrap(tokenRequest.httpBody)
        let body = String(data: httpBody, encoding: .utf8)?.split(separator: "&")
        XCTAssertEqual(tokenRequest.url, URL(string: "https://token.build.account.gov.uk/token"))
        XCTAssertEqual(contentTypeHeader, "application/x-www-form-urlencoded")
        XCTAssertEqual(appIntegrityHeaders, "testValue")
        XCTAssertEqual(httpMethod, "POST")
        XCTAssertEqual(body?[0], "grant_type=refresh_token")
        XCTAssertEqual(body?[1], "refresh_token=testRefreshToken")
    }
    
    func test_serviceTokenExchange() throws {
        let tokenRequest = URLRequest.serviceTokenExchange(
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
        XCTAssertEqual(body?[0], "subject_token_type=urn:ietf:params:oauth:token-type:access_token")
        XCTAssertEqual(body?[1], "grant_type=urn:ietf:params:oauth:grant-type:token-exchange")
        XCTAssertEqual(body?[2], "subject_token=tesSubjectToken")
        XCTAssertEqual(body?[3], "scope=testScope")
    }
}
