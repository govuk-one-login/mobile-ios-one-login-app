import Foundation
@testable import OneLogin
import Testing

final class URLRequestTests {
    @Test
    func test_refreshTokenExchange() async throws {
        let tokenRequest = try await URLRequest.refreshTokenExchange(
            token: "testRefreshToken",
            appIntegrityProvider: MockAppIntegrityProvider()
        )

        let contentTypeHeader = tokenRequest.value(forHTTPHeaderField: "Content-Type")
        let appIntegrityHeaders = tokenRequest.value(forHTTPHeaderField: "testAsserion")
        let httpMethod = tokenRequest.httpMethod
        let httpBody = try #require(tokenRequest.httpBody)
        let body = String(data: httpBody, encoding: .utf8)?.split(separator: "&")
        #expect(tokenRequest.url == URL(string: "https://token.build.account.gov.uk/token"))
        #expect(contentTypeHeader == "application/x-www-form-urlencoded")
        #expect(appIntegrityHeaders == "testValue")
        #expect(httpMethod == "POST")
        #expect(body?[0] == "grant_type=refresh_token")
        #expect(body?[1] == "refresh_token=testRefreshToken")
    }
    
    @Test
    func test_serviceTokenExchange() throws {
        let tokenRequest = URLRequest.serviceTokenExchange(
            subjectToken: "tesSubjectToken",
            scope: "testScope"
        )

        let contentTypeHeader = tokenRequest.value(forHTTPHeaderField: "Content-Type")
        let httpMethod = tokenRequest.httpMethod
        let httpBody = try #require(tokenRequest.httpBody)
        let body = String(data: httpBody, encoding: .utf8)?.split(separator: "&")
        #expect(tokenRequest.url == URL(string: "https://token.build.account.gov.uk/token"))
        #expect(contentTypeHeader == "application/x-www-form-urlencoded")
        #expect(httpMethod == "POST")
        #expect(body?[0] == "subject_token_type=urn:ietf:params:oauth:token-type:access_token")
        #expect(body?[1] == "grant_type=urn:ietf:params:oauth:grant-type:token-exchange")
        #expect(body?[2] == "subject_token=tesSubjectToken")
        #expect(body?[3] == "scope=testScope")
    }
}
