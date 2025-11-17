import AppIntegrity
import Foundation
import MockNetworking
@testable import Networking
@testable import OneLogin
import Testing

final class RefreshTokenExchangeManagerTests {
    var sut: RefreshTokenExchangeManager
    
    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]

        let client = NetworkClient(configuration: configuration)
        
        sut = RefreshTokenExchangeManager(networkClient: client)
    }
    
    deinit {
        MockURLProtocol.clear()
        // sut = nil
    }
    
    @Test("refresh token exchange URL is correct")
    func refreshTokenExchange_URL() async throws {
        let refreshToken = "token"
        
        // GIVEN I am connected to the internet
        await confirmation("Received a network request") { exp in
            MockURLProtocol.handler = {
                exp()
                return (Data(), HTTPURLResponse(statusCode: 200))
            }
            
            // AND I have an valid refresh token
            Task {
                _ = try await sut.getUpdatedTokens(
                    refreshToken: refreshToken,
                    appIntegrityProvider: MockAppIntegrityProvider()
                )
            }
        }
        
        let request = try #require(MockURLProtocol.requests.first)
        
        #expect(request.url?.absoluteString == "https://token.build.account.gov.uk/token")
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/x-www-form-urlencoded")
        
        let data = try #require(request.httpBodyData())
        let body = String(data: data, encoding: .utf8)
        var components = URLComponents()
        components.query = body
        
        #expect(components.queryItems == [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ])
    }
    
    @Test("TokenResponse returned from exchange has correct values")
    func refreshTokenExchange_returnsTokenResponse() async throws {
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
        
        #expect(exchangeResponse.accessToken == "accessToken")
        #expect(exchangeResponse.refreshToken == "refreshToken")
        #expect(exchangeResponse.tokenType == "bearer")
        #expect(exchangeResponse.expiryDate <= Date(timeIntervalSinceNow: 180))
        #expect(exchangeResponse.idToken == nil)
    }
    
    @Test("If account intervention occurs during refresh token exchange, an error is thrown")
    func refreshTokenExchange_accountIntervention() async throws {
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
            Issue.record("Expected `` error to be thrown")
        }
    }
}
