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
            throw OneLoginError(.network)
        } catch {
            throw OneLoginError(
                .requestFailed,
                originalError: error
            )
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
                throw OneLoginError(.reauthenticationRequired)
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
            let error = handleServerError(error)
            throw error
        } catch {
            throw OneLoginError(
                .requestFailed,
                originalError: error
            )
        }
    }
    
    private func performRefreshExchangeAndSaveTokens(
        idToken: String,
        refreshToken: String
    ) async throws {
        do {
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
        } catch RefreshTokenExchangeError.noInternet {
            throw OneLoginError(.network)
        } catch let error as FirebaseAppCheckError where error.errorType == .network {
            throw OneLoginError(.network)
        }
    }
    
    private func handleServerError(_ error: ServerError) -> Error {
        guard let data = error.response,
              let errorType = try? JSONDecoder().decode(ServerErrorResponse.self, from: data),
              errorType.error == .invalidGrant else {
            // Build environment throws 400 invalid_target so we shouldn't log the user out in that case
            return error // TODO: Should i keep this error or transform to OneLoginError(.requestFailed)
        }
        NotificationCenter.default.post(name: .accountIntervention)
        return OneLoginError(.reauthenticationRequired)
    }
}
