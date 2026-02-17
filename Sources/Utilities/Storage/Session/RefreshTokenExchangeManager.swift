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
    
    init(networkClient: NetworkClient = NetworkClient()) {
        self.networkClient = networkClient
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
        } catch let error as FirebaseAppCheckError where error.kind == .network {
            // Transformed to enable offline wallet
            throw RefreshTokenExchangeError.noInternet
        } catch _ as FirebaseAppCheckError {
            // All other FirebaseAppCheckErrors are treated as unrecoverable
            throw RefreshTokenExchangeError.appIntegrityFailed
        } catch _ as ClientAssertionError {
            // All ClientAssertionErrors are treated as unrecoverable
            throw RefreshTokenExchangeError.appIntegrityFailed
        } catch _ as ProofOfPossessionError {
            // All ProofOfPossessionErrors are treated as unrecoverable
            throw RefreshTokenExchangeError.appIntegrityFailed
        }
    }
}
