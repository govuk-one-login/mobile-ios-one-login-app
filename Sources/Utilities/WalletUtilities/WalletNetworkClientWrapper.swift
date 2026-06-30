import Networking
import UIKit

enum SessionError: Error {
    case expired
}

public final class WalletNetworkClientWrapper: NetworkClientProtocol {
    private let networkingService: OneLoginNetworkingService
    private let sessionManager: SessionManager
    
    init(networkingService: OneLoginNetworkingService,
         sessionManager: SessionManager) {
        self.networkingService = networkingService
        self.sessionManager = sessionManager
    }
    
    public func makeRequest(_ request: NetworkRequest) async throws -> Data {
        guard sessionManager.sessionState != .expired else {
            NotificationCenter.default.post(name: .sessionExpired)
            throw SessionError.expired
        }
        return try await networkingService.makeRequest(request)
    }
}
