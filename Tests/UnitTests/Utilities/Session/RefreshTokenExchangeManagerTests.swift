import AppIntegrity
import MockNetworking
@testable import Networking
@testable import OneLogin
import XCTest

final class RefreshTokenExchangeManagerTests: XCTestCase {
    var sut: RefreshTokenExchangeManager!
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        let client = NetworkClient(configuration: configuration)
        
        sut = RefreshTokenExchangeManager(networkClient: client)
    }
    
    override func tearDown() {
        MockURLProtocol.clear()
        sut = nil
        super.tearDown()
    }
    
    func test_refreshTokenExchangeURL() async throws {
        // GIVEN I am connected to the internet
        let exp = expectation(description: "Received a network request")
        exp.assertForOverFulfill = true

        MockURLProtocol.handler = {
            exp.fulfill()
            return (Data(), HTTPURLResponse(statusCode: 200))
        }

        // AND I have an valid refresh token
        let refreshToken = UUID().uuidString
        Task {
            _ = try await sut.getUpdatedTokens(
                refreshToken: refreshToken,
                appIntegrityProvider: MockAppIntegrityProvider()
            )
        }
        
        // THEN a request is made to exchange the access token
        await fulfillment(of: [exp], timeout: 5)
        
        let request = try XCTUnwrap(MockURLProtocol.requests.first)
        
        XCTAssertEqual(request.url?.absoluteString,
                       "https://token.build.account.gov.uk/token")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"),
                       "application/x-www-form-urlencoded")
        
        let data = try XCTUnwrap(request.httpBodyData())
        let body = String(data: data, encoding: .utf8)
        var components = URLComponents()
        components.query = body

        XCTAssertEqual(components.queryItems, [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ])
    }
    
    func test_returnsTokenResponse() async throws {
        MockURLProtocol.handler = {
            let response = """
            {
                "access_token": "accessToken",
                "refresh_token": "refreshToken",
                "token_type": "bearer",
                "expires_in": 180
            }
            """
            return (Data(response.utf8), HTTPURLResponse(statusCode: 200))
        }
        
        // WHEN I attempt refresh exchange
        let exchangeResponse = try await sut.getUpdatedTokens(
            refreshToken: UUID().uuidString,
            appIntegrityProvider: MockAppIntegrityProvider()
        )
        
        // THEN the expected TokenResponse values are populated
        XCTAssertNotNil(exchangeResponse.accessToken)
        XCTAssertNotNil(exchangeResponse.refreshToken)
        XCTAssertNotNil(exchangeResponse.tokenType)
        XCTAssertNotNil(exchangeResponse.expiryDate)
        XCTAssertNil(exchangeResponse.idToken)
    }
    
    func test_appIntegrityProvider_accountIntervention() async throws {
        do {
            let error = ClientAssertionError.init(
                .invalidPublicKey,
                errorDescription: "error thrown due to account intervention")
            
            _ = try await sut.getUpdatedTokens(
                refreshToken: UUID().uuidString,
                appIntegrityProvider: MockAppIntegrityProvider(errorThrownAssertingIntegrity: error)
            )
        } catch let error as ClientAssertionError where error.errorType == .invalidPublicKey {
            // expected path
        } catch {
            XCTFail("Expected `` error to be thrown")
        }
    }
}
