@testable import Networking
@testable import OneLogin
import PactSwift
import XCTest

class MockProvider {
    static let shared = MockProvider()
    var mockService: MockService
    
    private init() {
        mockService = MockService(consumer: "Mobile.MobilePlatform.OneLoginAppIOS",
                                  provider: "Mobile.MobilePlatform.StsBackendApi")
    }
}

final class OneLoginPactTests: XCTestCase {
    
    var networkClient: NetworkClient?
    var mockTokenVerifier: MockTokenVerifier!
    var jsonDecoder: JSONDecoder!
    
    override func setUp() {
        super.setUp()
        
        mockTokenVerifier = MockTokenVerifier()
        networkClient = NetworkClient()
    }
    
    override func tearDown() {
        mockTokenVerifier = nil
        networkClient = nil
    }
    
    // swiftlint:disable line_length
//    func testTokenExchangeRequest() {
//        
//        MockProvider.shared.mockService
//            .uponReceiving("A token exchange request")
//            .withRequest(method: .POST, path: "/token",
//                         headers: ["Content-Type": "application/x-www-form-urlencoded"],
//                         body: "grant_type=urn:ietf:params:oauth:grant-type:token-exchange&scope=sts-test.hello-world.read&subject_token=subjectToken&subject_token_type=urn:ietf:params:oauth:token-type:access_token")
//            .willRespondWith(status: 200,
//                             headers: ["Content-Type": "application/json"],
//                             body: [ "access_token": "accessToken",
//                                     "token_type": "Bearer",
//                                     "expires_in": 180])
//        
//        MockProvider.shared.mockService.run(timeout: 60) { baseURL, testComplete in
//            Task {
//                let request = URLRequest(url: URL(string: "\(baseURL)/token")!)
//                let tokenExchangeRequest = request.tokenExchange(subjectToken: "subjectToken", scope: "sts-test.hello-world.read")
//                let result = try await self.networkClient?.makeRequest(tokenExchangeRequest)
//                let jsonDecoder = JSONDecoder()
//                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
//                
//                let tokenResponse = try jsonDecoder.decode(ServiceTokenResponse.self, from: result!)
//                XCTAssertEqual(tokenResponse.accessToken, "accessToken")
//                XCTAssertEqual(tokenResponse.tokenType, "Bearer")
//                XCTAssertEqual(tokenResponse.expiresIn, 180)
//                testComplete()
//            }
//        }
//    }
    // swiftlint:enable line_length
    
    
    @MainActor
    func testAccessTokenRequestWithNoPreviouslyRequestedScope() throws {
        
        MockProvider.shared.mockService
            .uponReceiving("a valid access token request with no previously requested scope")
            .given(ProviderState(description: "mock.auth.code is a valid authorization code",
                                 params: .init()),
                   ProviderState(description: "https://mock-redirect-uri.gov.uk is the redirect URI used in the authorization request",
                                 params: .init()),
                   ProviderState(description: "the code_challenge sent in the authorization request matches the verifier mock_code_verifier",
                                 params: .init()))
            .withRequest(
                method: .POST, path: "/token",
                headers: ["Content-Type": "application/x-www-form-urlencoded"],
                body: tokenQuery)
            .willRespondWith(status: 200,
                             headers: ["Content-Type": "application/json"],
                             body: [ "access_token": Matcher.SomethingLike("mockAccessToken"),
                                     "token_type": "Bearer",
                                     "expires_in": Matcher.SomethingLike(180)])
        
        MockProvider.shared.mockService.run(timeout: 20) { [unowned self] baseURL, testComplete in
            Task {
                let request = tokenRequest(baseURL)
                let result = try await self.networkClient?.makeRequest(request)
                
                let response = try XCTUnwrap(try? JSONSerialization.jsonObject(with: result!, options: []) as? [String: Any])
                let tokenType = try XCTUnwrap(response["token_type"] as? String)
                XCTAssertEqual(tokenType, "Bearer")
                
                // We only care that these values are String or Double, so the XCTUnwrap covers data validity
                _ = try XCTUnwrap(response["access_token"] as? String)
                _ = try XCTUnwrap(response["expires_in"] as? Double)
                testComplete()
            }
            
        }
    }
    
    @MainActor
    func testAccessTokenRequestWithPreviouslyRequestedScopeOfOpenId() throws {
        
        MockProvider.shared.mockService
            .uponReceiving("a valid access token request with a previously requested scope of openid")
            .given(ProviderState(description: "mock.auth.code is a valid authorization code",
                                 params: .init()),
                   ProviderState(description: "https://mock-redirect-uri.gov.uk is the redirect URI used in the authorization request",
                                 params: .init()),
                   ProviderState(description: "the code_challenge sent in the authorization request matches the verifier mock_code_verifier",
                                 params: .init()),
                   ProviderState(description: "a previously requested scope of openid",
                                 params: .init()))
            .withRequest(
                method: .POST, path: "/token",
                headers: ["Content-Type": "application/x-www-form-urlencoded"],
                body: tokenQuery)
            .willRespondWith(status: 200,
                             headers: ["Content-Type": "application/json"],
                             body: [ "access_token": Matcher.SomethingLike("mockAccessToken"),
                                     "id_token": Matcher.RegexLike(value: "mockHeader.\(idTokenPayloadEncoded).mockSignature", pattern: "^(.+)\\.(.+)\\.(.+)$"),
                                     // Though we don't expect id_token_decoded in our actual responses, this is put here so that the generated
                                     // contract will include the matching requirements as implemented in idTokenPayload variable.
                                     "id_token_decoded": idTokenPayloadMatching,
                                     "token_type": "Bearer",
                                     "expires_in": Matcher.SomethingLike(180)])
        
        MockProvider.shared.mockService.run(timeout: 20) { [unowned self] baseURL, testComplete in
            Task {
                let request = tokenRequest(baseURL)
                let result = try await self.networkClient?.makeRequest(request)
                
                let response = try XCTUnwrap(try? JSONSerialization.jsonObject(with: result!, options: []) as? [String: Any])
                print("RESPONSE = \(response)")
                let tokenType = try XCTUnwrap(response["token_type"] as? String)
                let payload = try XCTUnwrap(response["id_token"] as? String)
                let verifier = JWTVerifier()
                let extracted = try XCTUnwrap(try verifier.extractPayload(payload))
                XCTAssertEqual(extracted.email, "email@example.com")
                XCTAssertEqual(extracted.persistentId, "mock_persistent_id")
                XCTAssertEqual(tokenType, "Bearer")
                testComplete()
            }
            
        }
    }

    private func tokenRequest(_ baseURL: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "\(baseURL)/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = tokenQuery?.data(using: .utf8)
        request.httpBody = body
        return request
    }
    
    private var tokenQuery: String? {
        var urlParser = URLComponents()
        urlParser.queryItems = [
            URLQueryItem(name: "code", value: "mock.auth.code"),
            URLQueryItem(name: "code_verifier'", value: "mock_code_verifier"),
            URLQueryItem(name: "redirect_uri", value: "https://mock-redirect-uri.gov.uk"),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        return urlParser.percentEncodedQuery
    }
    
    private var idTokenPayloadMatching: [String: Any] {
        ["email": Matcher.SomethingLike("email@example.com"),
         "email_verified": true,
         "persistent_id": Matcher.SomethingLike("mock_persistent_id")]
    }
    
    private var idTokenPayload: [String: Any] {
        ["email": "email@example.com",
         "email_verified": true,
         "persistent_id": "mock_persistent_id"]
    }
    
    private var idTokenPayloadEncoded: String {
        let data = try? JSONSerialization.data(withJSONObject: idTokenPayload)
        return data?.base64EncodedString() ?? "idTokenPayloadEncoded"
    }
}
