import AppIntegrity
import Authentication
import Foundation
import MobilePlatformServices
import Networking

protocol OneLoginNetworkClient {
    func makeRequest(_ request: URLRequest) async throws -> Data
    
    func makeAuthorizedRequest(
        scope: String,
        request: URLRequest
    ) async throws -> Data
}

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
    
    init(networkClient: NetworkClient = NetworkClient(),
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
        do {
            guard sessionManager.isAccessTokenValid else {
                if let refreshToken = sessionManager.returnRefreshTokenIfValid {
                    try await performRefreshExchangeAndSaveTokens(with: refreshToken)
                    
                    return try await networkClient.makeAuthorizedRequest(
                        scope: scope,
                        request: request
                    )
                } else {
                    // No valid access or refresh token, user must reauthenticate
                    NotificationCenter.default.post(name: .reauthenticationRequired)
                    throw RefreshTokenExchangeError.reauthenticationRequired
                }
            }
            
            return try await networkClient.makeAuthorizedRequest(
                scope: scope,
                request: request
            )
        } catch let error as URLError where error.code == .notConnectedToInternet
                    || error.code == .networkConnectionLost {
            throw error
        } catch {
            throw error
        }
    }
}

extension NetworkingService {
    func performRefreshExchangeAndSaveTokens(with refreshToken: String) async throws {
        let tokens = try await refreshExchangeManager.getUpdatedTokens(
            refreshToken: refreshToken,
            appIntegrityProvider: try FirebaseAppIntegrityService.firebaseAppCheck()
        )
        
        // Save new tokens
        try sessionManager.saveLoginTokens(
            tokenResponse: tokens,
            idToken: sessionManager.idToken
        )
    }
}
