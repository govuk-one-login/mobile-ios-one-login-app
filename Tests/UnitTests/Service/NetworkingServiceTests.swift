import AppIntegrity
import Foundation
import MockNetworking
@testable import Networking
@testable import OneLogin
import Testing

@Suite(.serialized)
struct NetworkingSerivceTests {
    let sut: NetworkingService
    let mockSessionManager: MockSessionManager
    var mockRefreshExchangeManager: MockRefreshTokenExchangeManager
    
    init() {
        MockURLProtocol.clear()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        let networkClient = NetworkClient(configuration: configuration)
        mockSessionManager = MockSessionManager()
        mockRefreshExchangeManager = MockRefreshTokenExchangeManager()
        
        sut = NetworkingService(
            networkClient: networkClient,
            refreshExchangeManager: mockRefreshExchangeManager,
            sessionManager: mockSessionManager,
            appIntegrityProvider: AppIntegrityProviderStub()
        )
        
        networkClient.authorizationProvider = self
    }
    
    @Test("Test makeRequest()")
    func test_makeRequest() async throws {
        MockURLProtocol.handler = {
            let data = Data("NetworkingService Test".utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }
        // .execute() calls makeRequest()
        let response = try await sut.request(URLRequest(url: URL(string: "testurl.com")!)).execute()
        
        #expect(String(data: response, encoding: .utf8) == "NetworkingService Test")
    }
    
    @Test("Test makeRequest() handles no internet")
    func test_makeRequest_noInternet() async throws {
        MockURLProtocol.handler = {
            throw URLError(.notConnectedToInternet)
        }
        
        do {
            // .execute() calls makeRequest()
            _ = try await sut.request(URLRequest(url: URL(string: "testurl.com")!)).execute()
        } catch URLError.notConnectedToInternet {
            // Expected path
        } catch {
            Issue.record("Expected `.notConnectedToInternet` error to be thrown")
        }
    }
    
    @Test("Test makeRequest() with network connection lost")
    func test_makeRequest_networkConnectionLost() async throws {
        MockURLProtocol.handler = {
            throw URLError(.networkConnectionLost)
        }
        
        do {
            _ = try await sut.request(URLRequest(url: URL(string: "testurl.com")!)).execute()
        } catch URLError.networkConnectionLost {
            // Expected path
        } catch {
            Issue.record("Expected `.networkConnectionLost` error to be thrown")
        }
    }
    
    @Test("Test Authorized request with valid accessToken")
    func test_makeAuthorisedRequest_validAccessToken() async throws {
        mockSessionManager.tokenProvider.update(accessToken: "token", accessTokenExpiry: Date().addingTimeInterval(3600))
        
        MockURLProtocol.handler = {
            let data = Data("NetworkingService Test".utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }
        
        let response = try await sut.request(URLRequest(url: URL(string: "testurl.com")!))
            .withAuthentication(scope: "")
            .execute()
        
        #expect(String(data: response, encoding: .utf8) == "NetworkingService Test")
    }
    
    @Test("Test Authorized request with invalid accessToken and valid refreshToken")
    func test_makeAuthorisedRequest_invalidAccessToken() async throws {
        mockSessionManager.tokenProvider.update(accessToken: "token", accessTokenExpiry: Date().addingTimeInterval(-3600))
        mockSessionManager.validTokensForRefreshExchange = ("refreshToken", "idToken")
        
        #expect(mockSessionManager.didCallSaveLoginTokens == false)
        
        MockURLProtocol.handler = {
            let data = Data("NetworkingService Test".utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }
        
        let response = try await sut.request(URLRequest(url: URL(string: "testurl.com")!))
            .withAuthentication(scope: "")
            .execute()
        
        // Saving tokens means refresh exchange was successful
        #expect(mockSessionManager.didCallSaveLoginTokens == true)
        
        #expect(String(data: response, encoding: .utf8) == "NetworkingService Test")
    }
    
    @Test("Test Authorized request with invalid tokens leads to reauthentication")
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
            _ = try await sut.request(URLRequest(url: URL(string: "testurl.com")!))
                .withAuthentication(scope: "")
                .execute()
            
            Issue.record("Expected `.reauthenticationRequired` error to be thrown")
        } catch RefreshTokenExchangeError.reauthenticationRequired {
            // Expected path
            let received = await iterator.next()?.name == .reauthenticationRequired
            if received == false {
                Issue.record("Expected reauthenticationRequired notification to be posted")
            }
        } catch {
            Issue.record("Expected `.reauthenticationRequired` error to be thrown")
        }
    }
    
    @Test("Test Authorized request with no internet")
    func test_makeAuthorizedRequest_noInternet() async throws {
        mockSessionManager.tokenProvider.update(accessToken: "token", accessTokenExpiry: Date().addingTimeInterval(3600))
       
        MockURLProtocol.handler = {
            throw URLError(.notConnectedToInternet)
        }
        
        do {
            _ = try await sut.request(URLRequest(url: URL(string: "testurl.com")!))
                .withAuthentication(scope: "")
                .execute()
        } catch URLError.notConnectedToInternet {
            // expected path
        } catch {
            Issue.record("Expected `.notConnectedToInternet` error to be thrown")
        }
    }
    
    @Test("Test Authorized request with network connection lost")
    func test_makeAuthorizedRequest_networkConnectionLost() async throws {
        mockSessionManager.tokenProvider.update(accessToken: "token", accessTokenExpiry: Date().addingTimeInterval(3600))
       
        MockURLProtocol.handler = {
            throw URLError(.networkConnectionLost)
        }
        
        do {
            _ = try await sut.request(URLRequest(url: URL(string: "testurl.com")!))
                .withAuthentication(scope: "")
                .execute()
        } catch URLError.networkConnectionLost {
            // expected path
        } catch {
            Issue.record("Expected `.networkConnectionLost` error to be thrown")
        }
    }
    
    @Test("Test Authorized request does not violate getUpdatedTokens which expects a refresh token to only be used once.")
    func test_makeAuthorisedRequest_invalidAccessToken_concurrent() async throws {
        // Create a mockSessionManager that uses PersistenSessionManager
        // So the stored tokens are overwritten during the test
        let mockSessionManager = try createPersistentSessionManager()
        
        // Create a network client
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let networkClient = NetworkClient(configuration: configuration)
        
        MockURLProtocol.handler = {
            let data = Data("NetworkingService Test".utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }
        
        // Create sut
        let mockRefreshExchangeManager = MockRefreshTokenExchangeManagerGuarantor()
        let sut = NetworkingService(
            networkClient: networkClient,
            refreshExchangeManager: mockRefreshExchangeManager,
            sessionManager: mockSessionManager,
			appIntegrityProvider: AppIntegrityProviderStub()
        )
        sut.networkClient.authorizationProvider = self
        
        let numberOfTasks = 10
        await withTaskGroup { group in
            for _ in 1...numberOfTasks {
            group.addTask {
                    do {
                        _ = try await sut.request(URLRequest(url: URL(string: "testurl.com")!))
                            .withAuthentication(scope: "")
                            .execute()
                    } catch {
                        Issue.record(error)
                    }
                }
            }
        }
        
        #expect(mockRefreshExchangeManager.capturedRefreshTokens.count == numberOfTasks)
    }

    @Test("Test parallel calls to an Authorized request and `resumeSession()` does not violate getUpdatedTokens which expects a refresh token to only be used once.")
    func test_makeAuthorisedRequest_invalidAccessToken_concurrent_with_sessionManager() async throws {
        // Create a mockSessionManager that uses PersistenSessionManager
        // So the stored tokens are overwritten during the test
        let serialTaskQueue = SerialTaskQueue()
        let mockRefreshExchangeManager = MockRefreshTokenExchangeManagerGuarantor()
        let mockSessionManager = try createPersistentSessionManager(refreshExchangeManager: mockRefreshExchangeManager,
                                                                    serialTaskQueue: serialTaskQueue)
            
        // Create a network client
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let networkClient = NetworkClient(configuration: configuration)
        
        MockURLProtocol.handler = {
            let data = Data("NetworkingService Test".utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }
        
        // Create sut
        let sut = NetworkingService(
            networkClient: networkClient,
            refreshExchangeManager: mockRefreshExchangeManager,
            sessionManager: mockSessionManager,
            serialTaskQueue: serialTaskQueue,
			appIntegrityProvider: AppIntegrityProviderStub()
        )
        sut.networkClient.authorizationProvider = self
        
        let numberOfTasks = 10
        await withTaskGroup { group in
            for _ in 1...numberOfTasks {
            group.addTask {
                    do {
                        _ = try await sut.request(URLRequest(url: URL(string: "testurl.com")!))
                            .withAuthentication(scope: "")
                            .execute()
                        
                        try await mockSessionManager.resumeSession()
                    } catch {
                        Issue.record(error)
                    }
                }
            }
        }
        
        #expect(mockRefreshExchangeManager.capturedRefreshTokens.count == numberOfTasks * 2)
    }
}

extension NetworkingSerivceTests {
    func createPersistentSessionManager(
        refreshExchangeManager: TokenExchangeManaging = MockRefreshTokenExchangeManager(),
        serialTaskQueue: SerialTaskQueue = SerialTaskQueue()
    ) throws -> PersistentSessionManager {
        let date = Date.distantFuture
        
        // Save refresh token and persistentSessionID
        let mockEncryptedStore: MockSecureStoreService = MockSecureStoreService()
        try mockEncryptedStore.saveItem(
            item: date.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        try mockEncryptedStore.saveItem(
            item: UUID().uuidString,
            itemName: OLString.persistentSessionID
        )
        
        // Save tokens
        let mockAccessControlEncryptedStore: MockSecureStoreService = MockSecureStoreService()
        let data = StoredTokens.encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            accessToken: MockJWTs.genericToken
        )
        try mockAccessControlEncryptedStore.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )
        
        // Set up local auth and ensure user is returning
        let mockLocalAuthentication = MockLocalAuthManager()
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        let mockUnprotectedStore = MockDefaultsStore()
        mockUnprotectedStore.savedData = [OLString.returningUser: true]
        
        return PersistentSessionManager(
            accessControlEncryptedStore: mockAccessControlEncryptedStore,
            encryptedStore: mockEncryptedStore,
            unprotectedStore: mockUnprotectedStore,
            localAuthentication: mockLocalAuthentication,
            analyticsService: MockAnalyticsService(),
            walletSDK: MockWalletSDKWrapper(),
            tokenExchangeManager: refreshExchangeManager,
            serialTaskQueue: serialTaskQueue
        )
    }
}

extension NetworkingSerivceTests: AuthorizationProvider {
    func fetchToken(withScope scope: String) async throws -> String {
        "mock_token"
    }
}
