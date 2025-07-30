import Networking
@testable import OneLogin
import Wallet
import XCTest

@MainActor
final class WalletNetworkClientWrapperTests: XCTestCase {
    var mockSessionManager: MockSessionManager!
    var networkClient: NetworkClient!
    var sut: WalletNetworkClientWrapper!
    
    override func setUpWithError() throws {
        super.setUp()
        
        mockSessionManager = MockSessionManager()
        networkClient = NetworkClient()
        sut = WalletNetworkClientWrapper(networkClient: networkClient,
                                         sessionManager: mockSessionManager)
    }
    
    override func tearDown() {
        mockSessionManager = nil
        networkClient = nil
        sut = nil
        
        super.tearDown()
    }
}

extension WalletNetworkClientWrapperTests {
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
