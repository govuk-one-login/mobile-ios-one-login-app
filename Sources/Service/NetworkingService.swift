import AppIntegrity
import Authentication
import Foundation
import MobilePlatformServices
import Networking

final class NetworkingService {
    let networkClient: NetworkClient
    let sessionManager: SessionManager
    private let appIntegrityProvider: () throws -> AppIntegrityProvider
    let refreshExchangeManager: TokenExchangeManaging
    
    convenience init(networkClient: NetworkClient = NetworkClient(),
                     refreshExchangeManager: TokenExchangeManaging = RefreshTokenExchangeManager(),
                     sessionManager: SessionManager) {
        self.init(networkClient: networkClient,
                  refreshExchangeManager: refreshExchangeManager,
                  sessionManager: sessionManager,
                  appIntegrityProvider: try FirebaseAppIntegrityService.firebaseAppCheck())
    }
    init(
        networkClient: NetworkClient = NetworkClient(),
        refreshExchangeManager: TokenExchangeManaging = RefreshTokenExchangeManager(),
        sessionManager: SessionManager,
        appIntegrityProvider: @autoclosure @escaping () throws -> AppIntegrityProvider) {
        self.networkClient = networkClient
        self.refreshExchangeManager = refreshExchangeManager
        self.sessionManager = sessionManager
        self.appIntegrityProvider = appIntegrityProvider
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
                
                return try await networkClient.makeAuthorizedRequest(
                    scope: scope,
                    request: request
                )
            } else {
                // No refresh token or id token or valid access token, user must reauthenticate
                NotificationCenter.default.post(name: .reauthenticationRequired)
                throw RefreshTokenExchangeError.reauthenticationRequired
            }
        }
        
        return try await networkClient.makeAuthorizedRequest(
            scope: scope,
            request: request
        )
    }
}

extension NetworkingService {
    private func performRefreshExchangeAndSaveTokens(
        idToken: String,
        refreshToken: String
    ) async throws {
        let tokenResponse = try await refreshExchangeManager.getUpdatedTokens(
            refreshToken: refreshToken,
            appIntegrityProvider: try appIntegrityProvider()
        )
        
        // Save new tokens
        try sessionManager.saveLoginTokens(
            idToken: idToken,
            refreshToken: tokenResponse.refreshToken,
            accessToken: tokenResponse.accessToken,
            accessTokenExpiry: tokenResponse.expiryDate
        )
    }
}
