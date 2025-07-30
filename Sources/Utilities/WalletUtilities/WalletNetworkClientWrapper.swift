import Networking
import UIKit
import Wallet

public final class WalletNetworkClientWrapper: WalletNetworkClient {
    private let networkClient: NetworkClient
    private let sessionManager: SessionManager
    
    init(networkClient: NetworkClient,
         sessionManager: SessionManager) {
        self.networkClient = networkClient
        self.sessionManager = sessionManager
    }
    
    public func makeRequest(_ request: URLRequest) async throws -> Data {
        switch sessionManager.sessionState {
        case .expired:
            NotificationCenter.default.post(name: .sessionExpired)
            throw TokenError.expired
        default:
            try await networkClient.makeRequest(request)
        }
    }
    
    public func makeAuthorizedRequest(
        scope: String,
        request: URLRequest
    ) async throws -> Data {
        switch sessionManager.sessionState {
        case .expired:
            NotificationCenter.default.post(name: .sessionExpired)
            throw TokenError.expired
        default:
            try await networkClient.makeAuthorizedRequest(scope: scope, request: request)
        }
    }
}
