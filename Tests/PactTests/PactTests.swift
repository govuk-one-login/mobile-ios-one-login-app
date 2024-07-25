@testable import Authentication
@testable import Networking
@testable import OneLogin
import PactSwift
import XCTest

class MockProvider {
    static let shared = MockProvider()
    var mockService: MockService

    private init() {
        mockService = MockService(consumer: "Mobile.MobilePlatform.OneLoginApp",
                                  provider: "Mobile.MobilePlatform.StsBackendApi")
    }
}

final class OneLoginPactTests: XCTestCase {

    var mockService: MockService!
    var networkClient: NetworkClient?
    var mockTokenVerifier: MockTokenVerifier!

    override func setUp() {
        super.setUp()

        mockTokenVerifier = MockTokenVerifier()
        mockService = MockProvider.shared.mockService
        networkClient = NetworkClient()
    }

    override func tearDown() {
        mockTokenVerifier = nil
        networkClient = nil
    }

    // swiftlint:disable line_length
        func testTokenExchangeRequest() {

            mockService
                .uponReceiving("A token exchange request")
                .withRequest(method: .POST, path: "/token",
                             headers: ["Content-Type": "application/x-www-form-urlencoded"],
                             body: "grant_type=urn:ietf:params:oauth:grant-type:token-exchange&scope=sts-test.hello-world.read&subject_token=subjectToken&subject_token_type=urn:ietf:params:oauth:token-type:access_token")
                .willRespondWith(status: 200,
                                 headers: ["Content-Type": "application/json"],
                                 body: [ "access_token": "accessToken",
                                         "token_type": "Bearer",
                                         "expires_in": 180])

            mockService.run(timeout: 60) { baseURL, testComplete in
                Task {
                    let request = URLRequest(url: URL(string: "\(baseURL)/token")!)
                    let tokenExchangeRequest = request.tokenExchange(subjectToken: "subjectToken", scope: "sts-test.hello-world.read")
                    let result = try await self.networkClient?.makeRequest(tokenExchangeRequest)
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

                    let tokenResponse = try jsonDecoder.decode(ServiceTokenResponse.self, from: result!)
                    XCTAssertEqual(tokenResponse.accessToken, "accessToken")
                    XCTAssertEqual(tokenResponse.tokenType, "Bearer")
                    XCTAssertEqual(tokenResponse.expiresIn, 180)
                    testComplete()
                }
            }
        }

        // swiftlint:enable line_length
        @MainActor
        func testAuthorizationRequest() throws {
            let mockIDToken = MockJWKSResponse.idToken
            var urlParser = URLComponents()
            urlParser.queryItems = [
                URLQueryItem(name: "mock_auth_code", value: "mockAuthCode"),
                URLQueryItem(name: "code_challenge'", value: "jM6oX_w_wU4biA2hDwmy0nkC_JsgvJRxaX0D-w1Hou0"),
                URLQueryItem(name: "redirect_uri", value: "https://mock-redirect-uri.gov.uk"),
                URLQueryItem(name: "client_id", value: "bYrcuRVvnylvEgYSSbBjwXzHrwJ"),
                URLQueryItem(name: "grant_type", value: "authoriztion_code")
            ]
            mockService
                .uponReceiving("An authorization request")
                .given(ProviderState(description: "mock_auth_code is a valid authorization code",
                                 params: .init()),
                          ProviderState(description: "https://mock-redirect-uri.gov.uk is the redirect URI used in the authorization request",
                                 params: .init()),
                          ProviderState(description: "the code_challenge sent in the authorization request matches the verifier mock_code_verifier",
                                 params: .init()))
                .withRequest(
                    method: .POST, path: "/token",
                             headers: ["Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"],
                             body: urlParser.percentEncodedQuery)
                .willRespondWith(status: 200,
                                 headers: ["Content-Type": "application/json"],
                                 body: [ "access_token": Matcher.SomethingLike("accessToken"),
                                         "id_token": Matcher.SomethingLike(mockIDToken),
                                         "token_type": Matcher.SomethingLike("Bearer"),
                                         "expiry_date": Matcher.SomethingLike(180)])

            mockService.run(timeout: 10) { [unowned self] baseURL, testComplete in
                Task {
                    var request = URLRequest(url: URL(string: "\(baseURL)/token")!)
                    request.httpMethod = "POST"
                    request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")

                    let body = urlParser.percentEncodedQuery?.data(using: .utf8)
                    request.httpBody = body
                    let result = try await self.networkClient?.makeRequest(request)
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                    jsonDecoder.dateDecodingStrategy = .secondsSince1970

                    let tokenResponse = try jsonDecoder.decode(TokenResponse.self, from: result!)
                    let decodedIDToken = try self.mockTokenVerifier.extractPayload(tokenResponse.idToken!)

                    XCTAssertEqual(decodedIDToken?.aud, MockTokenVerifier.mockPayload.aud)
                    XCTAssertEqual(tokenResponse.accessToken, "accessToken")
                    XCTAssertEqual(tokenResponse.tokenType, "Bearer")
                    XCTAssertEqual(tokenResponse.expiryDate, Date(timeIntervalSince1970: 180))
                    testComplete()
                }

            }
        }

}
