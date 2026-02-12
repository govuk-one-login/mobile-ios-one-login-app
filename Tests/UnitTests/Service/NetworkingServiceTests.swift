import AppIntegrity
import Foundation
import GDSUtilities
import MockNetworking
@testable import Networking
@testable import OneLogin
import Testing

@Suite(.serialized)
struct NetworkingSerivceTests {
    let sut: NetworkingService
    let mockSessionManager: MockSessionManager
    
    init() {
        MockURLProtocol.clear()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        let networkClient = NetworkClient(configuration: configuration)
        mockSessionManager = MockSessionManager()
    
        sut = NetworkingService(
            networkClient: networkClient,
            refreshExchangeManager: MockRefreshTokenExchangeManager(),
            sessionManager: mockSessionManager
        )
        
        networkClient.authorizationProvider = self
    }
    
    @Test("Test makeRequest()")
    func test_makeRequest() async throws {
        MockURLProtocol.handler = {
            let data = Data("NetworkingService Test".utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }
        let response = try await sut.makeRequest(URLRequest(url: URL(string: "testurl.com")!))
        
        #expect(String(data: response, encoding: .utf8) == "NetworkingService Test")
    }
    
    @Test("Test makeRequest() handles no internet error")
    func test_makeRequest_noInternetError() async throws {
        MockURLProtocol.handler = {
            throw URLError(.notConnectedToInternet)
        }
        
        do {
            _ = try await sut.makeRequest(URLRequest(url: URL(string: "testurl.com")!))
        } catch OneLoginError(.network) {
            // Expected path
        } catch {
            Issue.record("Expected OneLoginError(.network) error to be thrown")
        }
    }
    
    @Test("Test makeRequest() with network connection lost")
    func test_makeRequest_networkConnectionLost() async throws {
        MockURLProtocol.handler = {
            throw URLError(.networkConnectionLost)
        }
        
        do {
            _ = try await sut.makeRequest(URLRequest(url: URL(string: "testurl.com")!))
        } catch OneLoginError(.network) {
            // Expected path
        } catch {
            Issue.record("Expected OneLoginError(.network) error to be thrown")
        }
    }
    
    @Test("Test makeRequest() handles unexpected error")
    func test_makeRequest_anyError() async throws {
        let orignalError = URLError(.badURL)
        
        MockURLProtocol.handler = {
            throw orignalError
        }
        
        do {
            _ = try await sut.makeRequest(URLRequest(url: URL(string: "testurl.com")!))
        } catch let error as OneLoginError where error.kind == .requestFailed {
            #expect (error.errorUserInfo["originalError"] as? String ==
                     "The operation couldn’t be completed. (NSURLErrorDomain error -1000.)")
        } catch {
            Issue.record("Expected OneLoginError(.requestFailed) error to be thrown")
        }
    }
    
    @Test("Test makeAuthorisedRequest() with valid accessToken")
    func test_makeAuthorisedRequest_validAccessToken() async throws {
        mockSessionManager.tokenProvider.update(accessToken: "token", accessTokenExpiry: Date().addingTimeInterval(3600))
        
        MockURLProtocol.handler = {
            let data = Data("NetworkingService Test".utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }
        
        let response = try await sut.makeAuthorizedRequest(
            scope: "",
            request: URLRequest(url: URL(string: "testurl.com")!)
        )
        
        #expect(String(data: response, encoding: .utf8) == "NetworkingService Test")
    }
    
    @Test("Test makeAuthorisedRequest() with valid accessToken but 400 server error with invalid_grant")
    func test_makeAuthorisedRequest_validAccessTokenButServerErrorWithInvalidGrant() async throws {
        mockSessionManager.tokenProvider.update(accessToken: "token", accessTokenExpiry: Date().addingTimeInterval(3600))
        let notification = NotificationCenter.default.notifications(named: .accountIntervention)
        let iterator = notification.makeAsyncIterator()
        
        let jsonResponse = #"{ "error": "invalid_grant" }"#
        
        MockURLProtocol.handler = {
            let data = Data(jsonResponse.utf8)
            return (data, HTTPURLResponse(statusCode: 400))
        }
        
        do {
            _ = try await sut.makeAuthorizedRequest(scope: "", request: URLRequest(url: URL(string: "testurl.com")!))
            Issue.record("Expect 400 error, but no error thrown")
        } catch let error as any GDSError {
            #expect(error.kind.rawValue == OneLoginErrorKind.reauthenticationRequired.rawValue)
            let received = await iterator.next()?.name == .accountIntervention
            #expect(received == true)
        }
    }
    
    @Test("Test makeAuthorisedRequest() with invalid accessToken and valid refreshToken")
    func test_makeAuthorisedRequest_invalidAccessToken() async throws {
        mockSessionManager.tokenProvider.update(accessToken: "token", accessTokenExpiry: Date().addingTimeInterval(-3600))
        mockSessionManager.validTokensForRefreshExchange = ("refreshToken", "idToken")
        
        #expect(mockSessionManager.didCallSaveLoginTokens == false)
        
        MockURLProtocol.handler = {
            let data = Data("NetworkingService Test".utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }
        
        let response = try await sut.makeAuthorizedRequest(
            scope: "",
            request: URLRequest(url: URL(string: "testurl.com")!)
        )
        
        // Saving tokens means refresh exchange was successful
        #expect(mockSessionManager.didCallSaveLoginTokens == true)
        
        #expect(String(data: response, encoding: .utf8) == "NetworkingService Test")
    }
    
    @Test("Test makeAuthorisedRequest() with invalid tokens leads to reauthentication")
    func test_makeAuthorizedRequest_invalidTokens() async throws {
        let notification = NotificationCenter.default.notifications(named: .reauthenticationRequired)
        let iterator = notification.makeAsyncIterator()
        mockSessionManager.tokenProvider.update(accessToken: "token", accessTokenExpiry: Date().addingTimeInterval(-3600))
        mockSessionManager.validTokensForRefreshExchange = nil
        
        MockURLProtocol.handler = {
            let data = Data("NetworkingService Test".utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }
        
        do {
            _ = try await sut.makeAuthorizedRequest(
                scope: "",
                request: URLRequest(url: URL(string: "testurl.com")!)
            )
            
            Issue.record("Expected `.reauthenticationRequired` error to be thrown")
        } catch OneLoginError(.reauthenticationRequired) {
            // Expected path
            let received = await iterator.next()?.name == .reauthenticationRequired
            if received == false {
                Issue.record("Expected reauthenticationRequired notification to be posted")
            }
        } catch {
            Issue.record("Expected `.reauthenticationRequired` error to be thrown")
        }
    }
    
    @Test("Test makeAuthorisedRequest() with no internet")
    func test_makeAuthorizedRequest_noInternet() async throws {
        mockSessionManager.tokenProvider.update(accessToken: "token", accessTokenExpiry: Date().addingTimeInterval(3600))
       
        MockURLProtocol.handler = {
            throw URLError(.notConnectedToInternet)
        }
        
        do {
            _ = try await sut.makeAuthorizedRequest(
                scope: "",
                request: URLRequest(url: URL(string: "testurl.com")!)
            )
        } catch OneLoginError(.network) {
            // expected path
        } catch {
            Issue.record("Expected `.notConnectedToInternet` error to be thrown")
        }
    }
    
    @Test("Test makeAuthorisedRequest() with network connection lost")
    func test_makeAuthorizedRequest_networkConnectionLost() async throws {
        mockSessionManager.tokenProvider.update(accessToken: "token", accessTokenExpiry: Date().addingTimeInterval(3600))
       
        MockURLProtocol.handler = {
            throw URLError(.networkConnectionLost)
        }
        
        do {
            _ = try await sut.makeAuthorizedRequest(
                scope: "",
                request: URLRequest(url: URL(string: "testurl.com")!)
            )
        } catch OneLoginError(.network) {
            // expected path
        } catch {
            Issue.record("Expected `.networkConnectionLost` error to be thrown")
        }
    }
}

extension NetworkingSerivceTests: AuthorizationProvider {
    func fetchToken(withScope scope: String) async throws -> String {
        "mock_token"
    }
}
