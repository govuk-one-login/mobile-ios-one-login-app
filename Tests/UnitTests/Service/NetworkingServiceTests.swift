import AppIntegrity
import Foundation
import MockNetworking
@testable import Networking
@testable import OneLogin
import Testing

extension NetworkingService {
    
    static func make(refreshTokenExchangeManager: MockRefreshTokenExchangeManagerGuarantor = MockRefreshTokenExchangeManagerGuarantor()) throws -> NetworkingService {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let networkClient = NetworkClient(configuration: configuration)
        
        MockURLProtocol.handler = {
            let data = Data("NetworkingService Test".utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }

        let mockAccessControlEncryptedStore: MockSecureStoreService = MockSecureStoreService()
        let mockEncryptedStore: MockSecureStoreService = MockSecureStoreService()
        let date = Date.distantFuture
        try mockEncryptedStore.saveItem(
            item: date.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        
        let data = StoredTokens.encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            accessToken: MockJWTs.genericToken
        )
        try mockAccessControlEncryptedStore.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )

        let mockSessionManager: PersistentSessionManager = .make(mockAccessControlEncryptedStore: mockAccessControlEncryptedStore,
                                                                 mockEncryptedStore: mockEncryptedStore)

        return NetworkingService(
            networkClient: networkClient,
            refreshExchangeManager: refreshTokenExchangeManager,
            sessionManager: mockSessionManager
        )
    }
    
    static func usingResumeSessionPersistentSessionManager(refreshTokenExchangeManager: MockRefreshTokenExchangeManagerGuarantor = MockRefreshTokenExchangeManagerGuarantor()) throws -> (networkingService: NetworkingService, sessionManager: PersistentSessionManager) {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let networkClient = NetworkClient(configuration: configuration)
        
        MockURLProtocol.handler = {
            let data = Data("NetworkingService Test".utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }
        
        let mockLocalAuthentication = MockLocalAuthManager()
        let mockUnprotectedStore = MockDefaultsStore()
        mockLocalAuthentication.localAuthIsEnabledOnTheDevice = true
        mockUnprotectedStore.savedData = [OLString.returningUser: true]

        let mockEncryptedStore: MockSecureStoreService = MockSecureStoreService()
        let date = Date.distantFuture
        try mockEncryptedStore.saveItem(
            item: date.timeIntervalSince1970.description,
            itemName: OLString.refreshTokenExpiry
        )
        
        try mockEncryptedStore.saveItem(
            item: UUID().uuidString,
            itemName: OLString.persistentSessionID
        )

        let data = StoredTokens.encodeKeys(
            idToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            accessToken: MockJWTs.genericToken
        )
        
        let mockAccessControlEncryptedStore: MockSecureStoreService = MockSecureStoreService()
        try mockAccessControlEncryptedStore.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )

        let serialTaskQueue: SerialTaskQueue = SerialTaskQueue()
        let mockSessionManager: PersistentSessionManager = .make(mockAccessControlEncryptedStore: mockAccessControlEncryptedStore,
                                                                 mockEncryptedStore: mockEncryptedStore,
                                                                 mockUnprotectedStore: mockUnprotectedStore,
                                                                 mockLocalAuthentication: mockLocalAuthentication,
                                                                 serialTaskQueue: serialTaskQueue)

        return (networkingService: NetworkingService(
            networkClient: networkClient,
            refreshExchangeManager: refreshTokenExchangeManager,
            sessionManager: mockSessionManager,
            serialTaskQueue: serialTaskQueue
        ), sessionManager: mockSessionManager)
    }
}

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
    
    @Test("Test makeRequest() handles no internet")
    func test_makeRequest_noInternet() async throws {
        MockURLProtocol.handler = {
            throw URLError(.notConnectedToInternet)
        }
        
        do {
            _ = try await sut.makeRequest(URLRequest(url: URL(string: "testurl.com")!))
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
            _ = try await sut.makeRequest(URLRequest(url: URL(string: "testurl.com")!))
        } catch URLError.networkConnectionLost {
            // Expected path
        } catch {
            Issue.record("Expected `.networkConnectionLost` error to be thrown")
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
        } catch URLError.notConnectedToInternet {
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
        } catch URLError.networkConnectionLost {
            // expected path
        } catch {
            Issue.record("Expected `.networkConnectionLost` error to be thrown")
        }
    }
    
    @Test("Test makeAuthorisedRequest() does not violate getUpdatedTokens which expects a refresh token to only be used once.")
    func test_makeAuthorisedRequest_invalidAccessToken_concurrent() async throws {
        MockURLProtocol.clear()

        let refreshTokenExchangeManager = MockRefreshTokenExchangeManagerGuarantor()
        
        let sut: NetworkingService = try .make(refreshTokenExchangeManager: refreshTokenExchangeManager)
        sut.networkClient.authorizationProvider = self

        let numberOfTasks = 10
        await withTaskGroup { group in
            for _ in 1...numberOfTasks {
            group.addTask {
                    do {
                        _ = try await sut.makeAuthorizedRequest(
                            scope: "",
                            request: URLRequest(url: URL(string: "testurl.com")!)
                        )
                    } catch {
                        Issue.record(error)
                    }
                }
            }
        }
        
        #expect(refreshTokenExchangeManager.capturedRefreshTokens.count == numberOfTasks)
    }

    @Test("Test parallel calls to `makeAuthorisedRequest()` and `resumeSession()` does not violate getUpdatedTokens which expects a refresh token to only be used once.")
    func test_makeAuthorisedRequest_invalidAccessToken_concurrent_with_SessionManager() async throws {
        MockURLProtocol.clear()

        let refreshTokenExchangeManager = MockRefreshTokenExchangeManagerGuarantor()
        
        let sut = try NetworkingService.usingResumeSessionPersistentSessionManager(refreshTokenExchangeManager: refreshTokenExchangeManager)
        let networkingService: NetworkingService = sut.networkingService
        networkingService.networkClient.authorizationProvider = self
        let persistentSessionManager: PersistentSessionManager = sut.sessionManager

        let numberOfTasks = 10
        await withTaskGroup { group in
            for _ in 1...numberOfTasks {
            group.addTask {
                    do {
                        _ = try await networkingService.makeAuthorizedRequest(
                            scope: "",
                            request: URLRequest(url: URL(string: "testurl.com")!)
                        )
                        
                        try await persistentSessionManager.resumeSession(
                            tokenExchangeManager: refreshTokenExchangeManager,
                            appIntegrityProvider: MockAppIntegrityProvider()
                        )
                    } catch {
                        Issue.record(error)
                    }
                }
            }
        }
        
        #expect(refreshTokenExchangeManager.capturedRefreshTokens.count == numberOfTasks * 2)
    }

}

extension NetworkingSerivceTests: AuthorizationProvider {
    func fetchToken(withScope scope: String) async throws -> String {
        "mock_token"
    }
}
