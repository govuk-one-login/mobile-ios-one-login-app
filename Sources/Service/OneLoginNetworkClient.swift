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
    case reAuthenticationRequired
    case noValidAccessToken
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
            // Check if theres a valid access token
            guard persistentSessionManager.isAccessTokenValid else {
                // Check if theres valid refresh token
                if persistentSessionManager.isRefreshTokenValid {
                    // Yes - do refresh exchange to get new access token
                    if let refreshToken = persistentSessionManager.refreshToken {
                        let tokens = try await getUpdatedTokens(
                            refreshToken: refreshToken,
                            appIntegrityProvider: try FirebaseAppIntegrityService.firebaseAppCheck()
                        )
                        
                        // Update tokens in persistent session manager
                        try persistentSessionManager.saveLoginTokens(
                            tokenResponse: tokens,
                            idToken: persistentSessionManager.idToken
                        )
                        
                        return try await networkClient.makeAuthorizedRequest(
                            scope: scope,
                            request: request
                        )
                    }
                } else {
                    // no valid access & refresh token
                    NotificationCenter.default.post(name: .reAuthenticationRequired)
                    throw RefreshTokenExchangeError.reAuthenticationRequired
                }
                throw RefreshTokenExchangeError.noValidAccessToken
            }
            
            // If yes - make call to protected api
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
