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
    
    private(set) var appIntegrityRetries = 0
    
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
            throw RefreshTokenExchangeError.noInternet
        } catch let error as FirebaseAppCheckError where error.kind == .network {
            throw RefreshTokenExchangeError.noInternet
        } catch _ as FirebaseAppCheckError {
            // All other FirebaseAppCheckErrors are treated as unrecoverable
            throw RefreshTokenExchangeError.appIntegrityFailed
        } catch let error as ClientAssertionError {
            try handleClientAssertionError(
                error,
                refreshToken: refreshToken,
                appIntegrityProvider: appIntegrityProvider
            )
            throw RefreshTokenExchangeError.appIntegrityFailed
        } catch _ as ProofOfPossessionError {
            throw RefreshTokenExchangeError.appIntegrityFailed
        }
    }
    
    private func handleClientAssertionError(
        _ error: ClientAssertionError,
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) throws {
        switch error.kind {
        case .invalidToken,
             .serverError,
             .cantDecodeClientAssertion:
            appIntegrityRetries += 1
            
            if appIntegrityRetries <= 2 {
                Task {
                    try await Task.sleep(ms: 100 * UInt64(appIntegrityRetries))
                    
                    return try await getUpdatedTokens(
                        refreshToken: refreshToken,
                        appIntegrityProvider: appIntegrityProvider
                    )
                }
            } else {
                throw RefreshTokenExchangeError.appIntegrityFailed
            }
        case .invalidPublicKey:
            throw RefreshTokenExchangeError.appIntegrityFailed
        }
    }
}
