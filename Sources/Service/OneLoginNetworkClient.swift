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

final class NetworkingService: OneLoginNetworkingService, TokenExchangeManaging {
    let networkClient: NetworkClient
    let persistentSessionManager: PersistentSessionManager
    
    private(set) var errorRetries = 0
    
    init(networkClient: NetworkClient = NetworkClient(),
         persistentSessionManager: PersistentSessionManager) {
        self.networkClient = networkClient
        self.persistentSessionManager = persistentSessionManager
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
            guard persistentSessionManager.isAccessTokenValid else {
                if let refreshToken = persistentSessionManager.returnRefreshTokenIfValid {
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
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> TokenResponse {
        do {
            let exchangeResponse = try await makeRequest(
                .refreshTokenExchange(
                    token: refreshToken,
                    appIntegrityProvider: appIntegrityProvider
                )
            )
            
            return try JSONDecoder()
                .decode(TokenResponse.self, from: exchangeResponse)
        } catch let error as FirebaseAppCheckError where error.errorType == .generic
                    || error.errorType == .unknown {
            guard errorRetries < 3 else {
                throw RefreshTokenExchangeError.appIntegrityRetryError
            }
            errorRetries += 1
            return try await getUpdatedTokens(
                refreshToken: refreshToken,
                appIntegrityProvider: appIntegrityProvider
            )
        } catch let error as FirebaseAppCheckError where error.errorType == .network {
            throw RefreshTokenExchangeError.noInternet
        } catch let error as URLError where error.code == .notConnectedToInternet
                    || error.code == .networkConnectionLost {
            throw RefreshTokenExchangeError.noInternet
        } catch let error as ServerError where error.errorCode == 400 {
            NotificationCenter.default.post(name: .accountIntervention)
            throw RefreshTokenExchangeError.accountIntervention
        } catch {
            throw error
        }
    }
    
    private func performRefreshExchangeAndSaveTokens(with refreshToken: String) async throws {
        let tokens = try await getUpdatedTokens(
            refreshToken: refreshToken,
            appIntegrityProvider: try FirebaseAppIntegrityService.firebaseAppCheck()
        )
        
        // Save new tokens
        try persistentSessionManager.saveLoginTokens(
            tokenResponse: tokens,
            idToken: persistentSessionManager.idToken
        )
    }
}
