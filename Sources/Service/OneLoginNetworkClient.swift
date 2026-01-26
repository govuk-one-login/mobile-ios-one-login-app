import AppIntegrity
import Authentication
import Foundation
import MobilePlatformServices
import Networking

final class NetworkingService {
    let networkClient: NetworkClient
    let sessionManager: SessionManager
    let refreshExchangeManager: TokenExchangeManaging
    
    init(
        networkClient: NetworkClient = NetworkClient(),
        refreshExchangeManager: TokenExchangeManaging = RefreshTokenExchangeManager(),
        sessionManager: SessionManager
    ) {
        self.networkClient = networkClient
        self.refreshExchangeManager = refreshExchangeManager
        self.sessionManager = sessionManager
        self.networkClient.authorizationProvider = sessionManager.tokenProvider
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
        guard sessionManager.tokenProvider.isAccessTokenValid else {
            if let tokens = try sessionManager.validTokensForRefreshExchange {
                // Can throw a SecureStoreError(.biometricsCancelled) error which should propagate to caller
                try await performRefreshExchangeAndSaveTokens(
                    idToken: tokens.idToken,
                    refreshToken: tokens.refreshToken
                )
                
                return try await makeAuthorizedRequestRealiseAccountIntervention(
                    scope: scope,
                    request: request
                )
            } else {
                // No refresh token or id token or valid access token, user must reauthenticate
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
            handleServerError(error)
            throw error
        }
    }
    
    private func performRefreshExchangeAndSaveTokens(
        idToken: String,
        refreshToken: String
    ) async throws {
        let tokenResponse = try await refreshExchangeManager.getUpdatedTokens(
            refreshToken: refreshToken,
            appIntegrityProvider: try FirebaseAppIntegrityService.firebaseAppCheck()
        )
        
        // Save new tokens
        try sessionManager.saveLoginTokens(
            idToken: idToken,
            refreshToken: tokenResponse.refreshToken,
            accessToken: tokenResponse.accessToken,
            accessTokenExpiry: tokenResponse.expiryDate
        )
    }
    
    private func handleServerError(_ error: ServerError) {
        guard let data = error.response,
              let errorType = try? JSONDecoder().decode(ServerErrorResponse.self, from: data),
              errorType.error == .invalidGrant else {
            // Build environment throws 400 invalid_target so we shouldn't log the user out in that case
            return
        }
        NotificationCenter.default.post(name: .accountIntervention)
    }
}
