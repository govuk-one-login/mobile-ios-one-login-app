@testable import Authentication
@testable import Networking
@testable import OneLogin
import PactConsumerSwift
import XCTest

final class PactTests: XCTestCase {

    var mockService: MockService!
    var networkClient: NetworkClient?
    var mockTokenVerifier: MockTokenVerifier!

    override func setUp() {
        super.setUp()
        
        mockTokenVerifier = MockTokenVerifier()
        mockService = MockService(provider: "Mobile:MobilePlatform:DummyProvider",
                                  consumer: "OneLogin App")
        networkClient = NetworkClient()
    }

    override func tearDown() {
        mockTokenVerifier = nil
        mockService = nil
        networkClient = nil
    }

    func testMockRequest() {
        var request = URLRequest(url: URL(string: "http://localhost:1234/pact-test")!)
        let requestBody = MockRequestBody(request: "mock_request")
        let encoded = try? JSONEncoder().encode(requestBody)
        request.httpBody = encoded
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        mockService
            .uponReceiving("A Mock Request")
            .withRequest(method: .POST, path: "/pact-test",
                         headers: ["Content-Type": "application/json"],
                         body: ["request": "mock_request"])
            .willRespondWith(status: 200,
                             headers: ["Content-Type": "application/json"],
                             body: [ "response": "mock_response" ])

        mockService.run(timeout: 60) { [request] (testComplete) in
            Task {
                let result = try await self.networkClient?.makeRequest(request)
                let mockResponse = try JSONDecoder().decode(MockResponseBody.self, from: result!)
                XCTAssertEqual(mockResponse.response, "mock_response")
                testComplete()
            }
        }
    }
    
    // swiftlint:disable line_length
//    func testTokenExchangeRequest() {
//        var request = URLRequest(url: URL(string: "http://localhost:1234/token")!)
//        let tokenExchangeRequest = request.tokenExchange(subjectToken: "subjectToken", scope: "sts-test.hello-world.read")
//
//        mockService
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
//        mockService.run(timeout: 60) { [tokenExchangeRequest] (testComplete) in
//            Task {
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
//    @MainActor
//    func testAuthorizationRequest() throws {
//        let mockIDToken = MockJWKSResponse.idToken
//        
//        var request = URLRequest(url: URL(string: "http://localhost:1234/token")!)
//        request.httpMethod = "POST"
//        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
//        
//        var urlParser = URLComponents()
//        urlParser.queryItems = [
//            URLQueryItem(name: "code", value: "code"),
//            URLQueryItem(name: "code_verifier", value: "jM6oX_w_wU4biA2hDwmy0nkC_JsgvJRxaX0D-w1Hou0"),
//            URLQueryItem(name: "redirect_uri", value: "https://mobile.build.account.gov.uk/redirect"),
//            URLQueryItem(name: "client_id", value: "bYrcuRVvnylvEgYSSbBjwXzHrwJ"),
//            URLQueryItem(name: "grant_type", value: "authoriztion_code")
//        ]
//        let body = urlParser.percentEncodedQuery?.data(using: .utf8)
//        request.httpBody = body
//
//        mockService
//            .given("mock_auth_code is a valid authorization code")
//            .given("https://mock-redirect-uri.gov.uk is the redirect URI used in the authorization request")
//            .given("the code_challenge sent in the authorization request matches the verifier mock_code_verifier")
//            .uponReceiving("An authorization request")
//            .withRequest(method: .POST, path: "/token",
//                         headers: ["Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"],
//                         body: urlParser.percentEncodedQuery)
//            .willRespondWith(status: 200,
//                             headers: ["Content-Type": "application/json"],
//                             body: [ "access_token": Matcher.somethingLike("accessToken"),
//                                     "id_token": Matcher.somethingLike(mockIDToken),
//                                     "token_type": Matcher.somethingLike("Bearer"),
//                                     "expiry_date": Matcher.somethingLike(180)])
//
//        mockService.run(timeout: 10) { [request] (testComplete) in
//
//            Task {
//                let result = try await self.networkClient?.makeRequest(request)
//                let jsonDecoder = JSONDecoder()
//                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
//                jsonDecoder.dateDecodingStrategy = .secondsSince1970
//                
//                let tokenResponse = try jsonDecoder.decode(TokenResponse.self, from: result!)
//                let decodedIDToken = try self.mockTokenVerifier.extractPayload(tokenResponse.idToken!)
//
//                XCTAssertEqual(decodedIDToken?.aud, MockTokenVerifier.mockPayload.aud)
//                XCTAssertEqual(tokenResponse.accessToken, "accessToken")
//                XCTAssertEqual(tokenResponse.tokenType, "Bearer")
//                XCTAssertEqual(tokenResponse.expiryDate, Date(timeIntervalSince1970: 180))
//                testComplete()
//            }
//            
//        }
//    }
}
