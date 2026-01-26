import MockNetworking
@testable import Networking
@testable import OneLogin
import XCTest

@MainActor
final class WalletNetworkClientWrapperTests: XCTestCase {
    private var mockSessionManager: MockSessionManager!
    private var configuration: URLSessionConfiguration!
    private var networkClient: NetworkClient!
    private var sut: WalletNetworkClientWrapper!
    
    private var didRequestScope: String?

    override func setUpWithError() throws {
        super.setUp()
        
        mockSessionManager = MockSessionManager()
        configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        networkClient = NetworkClient(configuration: configuration)
        networkClient.authorizationProvider = self
        MockURLProtocol.clear()
        
        sut = WalletNetworkClientWrapper(networkClient: networkClient,
                                         sessionManager: mockSessionManager)
    }
    
    override func tearDown() {
        mockSessionManager = nil
        configuration = nil
        MockURLProtocol.clear()
        networkClient = nil
        sut = nil
        
        didRequestScope = nil
        
        super.tearDown()
    }
}

extension WalletNetworkClientWrapperTests {
    func test_requestSucceeded() async throws {
        MockURLProtocol.handler = {
            let data = Data("Wallet NetworkClient Test".utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }
        let response = try await sut.makeRequest(URLRequest(url: URL(string: "testurl.com")!))
        
        XCTAssertEqual(String(data: response, encoding: .utf8), "Wallet NetworkClient Test")
    }
    
    func test_requestError() async throws {
        let exp = XCTNSNotificationExpectation(
            name: .sessionExpired,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        
        mockSessionManager.sessionState = .expired
        do {
            _ = try await sut.makeRequest(URLRequest(url: URL(string: "testurl.com")!))
        } catch let error as SessionError {
            XCTAssert(error == SessionError.expired)
        }
        await fulfillment(of: [exp], timeout: 5)
    }
    
    func test_authRequestSucceeded() async throws {
        MockURLProtocol.handler = {
            let data = Data("Wallet NetworkClient Test".utf8)
            return (data, HTTPURLResponse(statusCode: 200))
        }
        let response = try await sut.makeAuthorizedRequest(scope: "test wallet scope", request: URLRequest(url: URL(string: "testurl.com")!))
        
        XCTAssertEqual(String(data: response, encoding: .utf8), "Wallet NetworkClient Test")
        XCTAssertEqual(didRequestScope, "test wallet scope")
    }
    
    func test_authRequestError() async throws {
        let exp = XCTNSNotificationExpectation(
            name: .sessionExpired,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        
        mockSessionManager.sessionState = .expired
        do {
            _ = try await sut.makeAuthorizedRequest(scope: "", request: URLRequest(url: URL(string: "testurl.com")!))
        } catch let error as SessionError {
            XCTAssert(error == SessionError.expired)
        }
        await fulfillment(of: [exp], timeout: 5)
    }
}

extension WalletNetworkClientWrapperTests: AuthorizationProvider {
    func fetchToken(withScope scope: String) async throws -> String {
        didRequestScope = scope
        return "mock_token"
    }
}
