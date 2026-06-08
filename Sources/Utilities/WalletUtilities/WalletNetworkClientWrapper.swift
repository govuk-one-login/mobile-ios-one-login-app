import Networking
import UIKit
import Wallet

enum SessionError: Error {
    case expired
}

public final class WalletNetworkClientWrapper: WalletNetworkClient, NetworkClientProtocol {
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

// TODO: DCMAW-20368 Remove this
extension WalletNetworkClientWrapper {
    @available(*, deprecated, message: "use request().execute() instead")
    public func makeRequest(_ request: URLRequest) async throws -> Data {
        guard sessionManager.sessionState != .expired else {
            NotificationCenter.default.post(name: .sessionExpired)
            throw SessionError.expired
        }
        return try await networkingService.makeRequest(request)
    }
    
    @available(*, deprecated, message: "use request().withAuthentication(scope).execute() instead")
    public func makeAuthorizedRequest(
        scope: String,
        request: URLRequest
    ) async throws -> Data {
        guard sessionManager.sessionState != .expired else {
            NotificationCenter.default.post(name: .sessionExpired)
            throw SessionError.expired
        }
        return try await networkingService.makeAuthorizedRequest(
            scope: scope,
            request: request
        )
    }
}
