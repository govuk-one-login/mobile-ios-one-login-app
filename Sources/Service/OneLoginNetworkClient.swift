import AppIntegrity
import Authentication
import Foundation
import MobilePlatformServices
import Networking
enum RefreshTokenExchangeError: Error {
    case accountIntervention
    case appIntegrityRetryError
    case noInternet
    case reauthenticationRequired
}

final class NetworkingService: OneLoginNetworkingService {
    let networkClient: NetworkClient
    let sessionManager: SessionManager
    let refreshExchangeManager: TokenExchangeManaging
    
    init(networkClient: NetworkClient,
         refreshExchangeManager: TokenExchangeManaging = RefreshTokenExchangeManager(),
         sessionManager: SessionManager) {
        self.networkClient = networkClient
        self.refreshExchangeManager = refreshExchangeManager
        self.sessionManager = sessionManager
    }
    
    func makeRequest(_ request: URLRequest) async throws -> Data {
        do {
            return try await networkClient.makeRequest(request)
        } catch let error as URLError where error.code == .notConnectedToInternet
                    || error.code == .networkConnectionLost {
            throw error
        }
    }
    
    func makeAuthorizedRequest(
        scope: String,
        request: URLRequest
    ) async throws -> Data {
        guard sessionManager.isAccessTokenValid else {
            if let tokens = try sessionManager.validTokensForRefreshExchange {
                // Can throw a SecureStoreError(.biometricsCancelled) error which should propagate to caller
                try await performRefreshExchangeAndSaveTokens(
                    refreshToken: tokens.refreshToken,
                    idToken: tokens.idToken
                )
                
                return try await makeAuthorizedRequestRealiseAccountIntervention(
                    scope: scope,
                    request: request
                )
            } else {
                // No refresh token or id token, user must reauthenticate
                NotificationCenter.default.post(name: .reauthenticationRequired)
                throw RefreshTokenExchangeError.reauthenticationRequired
            }
        }
        
        return try await makeAuthorizedRequestRealiseAccountIntervention(
            scope: scope,
            request: request
        )
    }
}

extension NetworkingService {
    private func makeAuthorizedRequestRealiseAccountIntervention(
        scope: String,
        request: URLRequest
    ) async throws -> Data {
        do {
            return try await networkClient.makeAuthorizedRequest(
                scope: scope,
                request: request
            )
        } catch let error as ServerError where error.errorCode == 400 {
            NotificationCenter.default.post(name: .accountIntervention)
            throw error
        }
    }
    
    private func performRefreshExchangeAndSaveTokens(
        refreshToken: String,
        idToken: String
    ) async throws {
        let tokens = try await refreshExchangeManager.getUpdatedTokens(
            refreshToken: refreshToken,
            appIntegrityProvider: try FirebaseAppIntegrityService.firebaseAppCheck()
        )
        
        // Save new tokens
        try sessionManager.saveLoginTokens(
            tokenResponse: tokens,
            idToken: idToken
        )
    }
}
