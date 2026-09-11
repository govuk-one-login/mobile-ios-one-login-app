import AppIntegrity
import Authentication
import Foundation
import MobilePlatformServices
import Networking

final class NetworkingService: NetworkClientProtocol {
    let networkClient: NetworkClient
    let sessionManager: SessionManager
    let serialTaskQueue: SerialTaskQueue
    
    init(
        networkClient: NetworkClient = NetworkClient(),
        sessionManager: SessionManager,
        serialTaskQueue: SerialTaskQueue = SerialTaskQueue(),
        appIntegrityProvider: @autoclosure @escaping () throws(AppIntegritySigningError) -> AppIntegrityProvider = try FirebaseAppIntegrityService.firebaseAppCheck()
    ) {
        self.networkClient = networkClient
        let authorizationProvider = networkClient.authorizationProvider ?? sessionManager.tokenProvider
        let clientAttestationProvider = networkClient.clientAttestationProvider ?? OneLoginAppIntegrityService(integrityService: appIntegrityProvider)
        let dPoPProvider = networkClient.dPoPProvider ?? OneLoginAppIntegrityService(integrityService: appIntegrityProvider)
        
        self.sessionManager = sessionManager
        self.networkClient.authorizationProvider = authorizationProvider
        self.networkClient.clientAttestationProvider = clientAttestationProvider
        self.networkClient.dPoPProvider = dPoPProvider
        self.serialTaskQueue = serialTaskQueue
    }
    
    func makeRequest(_ request: NetworkRequest) async throws -> Data {
        if request.authScope != nil {
            guard sessionManager.tokenProvider.isAccessTokenValid else {
                return try await self.serialTaskQueue.enqueue { @MainActor in
                    if let tokens = try self.sessionManager.validTokensForRefreshExchange {
                        // Can throw a SecureStoreError(.biometricsCancelled) error which should propagate to caller
                        try await self.sessionManager.refreshTokens(
                            idToken: tokens.idToken,
                            refreshToken: tokens.refreshToken
                        )
                        
                        return try await self.networkClient.makeRequest(request)
                    } else {
                        // No refresh token or id token or valid access token, user must reauthenticate
                        NotificationCenter.default.post(name: .reauthenticationRequired)
                        throw RefreshTokenExchangeError.reauthenticationRequired
                    }
                }
            }
        }
        
        do {
            return try await self.networkClient.makeRequest(request)
        } catch let error as URLError where error.code == .notConnectedToInternet
                    || error.code == .networkConnectionLost {
            throw error
        }
    }
}
