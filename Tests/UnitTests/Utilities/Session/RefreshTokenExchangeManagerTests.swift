import AppIntegrity
import Foundation
import MockNetworking
@testable import Networking
@testable import OneLogin
import Testing

@Suite(.serialized)
struct RefreshTokenExchangeManagerTests: ~Copyable {
    let sut: RefreshTokenExchangeManager
    
    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]

        let client = NetworkClient(configuration: configuration)
        
        sut = RefreshTokenExchangeManager(networkClient: client)
    }
    
    deinit {
        MockURLProtocol.clear()
    }
    
    @Test("refresh token exchange URL is correct")
    func refreshTokenExchange_URL() async throws {
        MockURLProtocol.handler = {
            (Data("""
            {
                "access_token": "accessToken",
                "refresh_token": "refreshToken",
                "token_type": "bearer",
                "expires_in": 180
            }
            """.utf8),
             HTTPURLResponse(statusCode: 200))
        }
        
        _ = try await sut.getUpdatedTokens(
            refreshToken: "refreshToken",
            appIntegrityProvider: MockAppIntegrityProvider()
        )
        
        let request = try #require(MockURLProtocol.requests.first)
        
        #expect(request.url?.absoluteString == "https://token.build.account.gov.uk/token")
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/x-www-form-urlencoded")
        
        let data = try #require(request.httpBodyData())
        let body = String(data: data, encoding: .utf8)
        #expect(body == "grant_type=refresh_token&refresh_token=refreshToken")
    }
    
    @Test("TokenResponse returned from exchange has correct values")
    func refreshTokenExchange_returnsTokenResponse() async throws {
        MockURLProtocol.handler = {
            (Data("""
            {
                "access_token": "accessToken",
                "refresh_token": "refreshToken",
                "token_type": "bearer",
                "expires_in": 180
            }
            """.utf8),
             HTTPURLResponse(statusCode: 200))
        }
        
        // WHEN I attempt refresh exchange
        let exchangeResponse = try await sut.getUpdatedTokens(
            refreshToken: UUID().uuidString,
            appIntegrityProvider: MockAppIntegrityProvider()
        )
        
        #expect(exchangeResponse.accessToken == "accessToken")
        #expect(exchangeResponse.refreshToken == "refreshToken")
        #expect(exchangeResponse.tokenType == "bearer")
        #expect(exchangeResponse.expiryDate.description == Date(timeIntervalSinceNow: 180).description)
        #expect(exchangeResponse.idToken == nil)
    }
    
    @Test("If a generic firebase error occurs, an error is thrown after 3 retires")
    func refreshTokenExchange_firebaseGenericError() async throws {
        let mockAppIntegrityProvider = MockAppIntegrityProvider()
        mockAppIntegrityProvider.errorThrownAssertingIntegrity = FirebaseAppCheckError(
            .generic,
            errorDescription: "test description"
        )
        
        do {
            _ = try await sut.getUpdatedTokens(
                refreshToken: UUID().uuidString,
                appIntegrityProvider: mockAppIntegrityProvider
            )
        } catch RefreshTokenExchangeError.appIntegrityRetryError {
            #expect(sut.errorRetries == 3)
        }
    }
    
    @Test("If a unknown firebase error occurs, an error is thrown after 3 retires")
    func refreshTokenExchange_firebaseUnknownError() async throws {
        let mockAppIntegrityProvider = MockAppIntegrityProvider()
        mockAppIntegrityProvider.errorThrownAssertingIntegrity = FirebaseAppCheckError(
            .unknown,
            errorDescription: "test description"
        )
        
        do {
            _ = try await sut.getUpdatedTokens(
                refreshToken: UUID().uuidString,
                appIntegrityProvider: mockAppIntegrityProvider
            )
        } catch RefreshTokenExchangeError.appIntegrityRetryError {
            #expect(sut.errorRetries == 3)
        }
    }
    
    @Test("If account intervention occurs during refresh token exchange, an error is thrown")
    func refreshTokenExchange_accountIntervention() async throws {
        MockURLProtocol.handler = {
            (Data("""
            """.utf8),
             HTTPURLResponse(statusCode: 400))
        }
        
        do {
            _ = try await sut.getUpdatedTokens(
                refreshToken: UUID().uuidString,
                appIntegrityProvider: MockAppIntegrityProvider()
            )
            
            // TODO: DCMAW-16211 check notification is being posted here
        } catch RefreshTokenExchangeError.accountIntervention {
            // expected path
        } catch {
            Issue.record("Expected `` error to be thrown")
        }
    }
    
    @Test("If a network firebase error occurs, an error is thrown")
    func refreshTokenExchange_firebaseNetworkError() async throws {
        let mockAppIntegrityProvider = MockAppIntegrityProvider()
        mockAppIntegrityProvider.errorThrownAssertingIntegrity = FirebaseAppCheckError(
            .network,
            errorDescription: "test description"
        )
        
        do {
            _ = try await sut.getUpdatedTokens(
                refreshToken: UUID().uuidString,
                appIntegrityProvider: mockAppIntegrityProvider
            )
        } catch RefreshTokenExchangeError.noInternet {
            // expected path
        } catch {
            Issue.record("Expected `` error to be thrown")
        }
    }
    
    @Test("If a no internet error occurs, an error is thrown")
    func refreshTokenExchange_notConnectedToInternet() async throws {
        MockURLProtocol.handler = {
            throw URLError(.notConnectedToInternet)
        }
        
        do {
            _ = try await sut.getUpdatedTokens(
                refreshToken: UUID().uuidString,
                appIntegrityProvider: MockAppIntegrityProvider()
            )
        } catch RefreshTokenExchangeError.noInternet {
            // expected path
        } catch {
            Issue.record("Expected `` error to be thrown")
        }
    }
    
    @Test("If a network connection lost error occurs, an error is thrown")
    func refreshTokenExchange_networkConnectionLost() async throws {
        MockURLProtocol.handler = {
            throw URLError(.networkConnectionLost)
        }
        
        do {
            _ = try await sut.getUpdatedTokens(
                refreshToken: UUID().uuidString,
                appIntegrityProvider: MockAppIntegrityProvider()
            )
        } catch RefreshTokenExchangeError.noInternet {
            // expected path
        } catch {
            Issue.record("Expected `` error to be thrown")
        }
    }
}
