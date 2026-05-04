import AppIntegrity
import Authentication
import Foundation
import Networking

protocol TokenExchangeManaging {
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> TokenResponse
}

final class RefreshTokenExchangeManager: TokenExchangeManaging {
    let networkClient: NetworkClient
    let networkMonitor: NetworkMonitoring
    
    init(networkClient: NetworkClient = NetworkClient(),
         networkMonitor: NetworkMonitoring = NetworkMonitor.shared) {
        self.networkClient = networkClient
        self.networkMonitor = networkMonitor
    }
    
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> TokenResponse {
        do {
            let exchangeResponse = try await networkClient.makeRequest(
                .refreshTokenExchange(
                    token: refreshToken,
                    appIntegrityProvider: appIntegrityProvider
                )
            )
            
            return try JSONDecoder()
                .decode(TokenResponse.self, from: exchangeResponse)
        } catch let error as ServerError where error.errorCode == 400 {
            NotificationCenter.default.post(name: .accountIntervention)
            throw error
        } catch let error as URLError where error.code == .notConnectedToInternet
                    || error.code == .networkConnectionLost {
            // Transformed to enable offline wallet
            throw RefreshTokenExchangeError.noInternet
        } catch let error as URLError where error.code == .timedOut {
            if networkMonitor.isConnectedToVPN {
                // Likely offline
                throw RefreshTokenExchangeError.noInternet
            } else {
                // Could be server, firewall, DNS etc
                throw error
            }
        } catch is FirebaseAppCheckError, is ClientAssertionError, is ProofOfPossessionError {
            // All treated as unrecoverable
            throw RefreshTokenExchangeError.appIntegrityFailed
        }
    }
}
