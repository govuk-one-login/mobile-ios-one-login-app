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
        } catch let error as FirebaseAppCheckError {
            handleFirebaseAppCheckError(
                error,
                refreshToken: refreshToken,
                appIntegrityProvider: appIntegrityProvider
            )
        } catch let error as ClientAssertionError {
            handleClientAssertionError(
                error,
                refreshToken: refreshToken,
                appIntegrityProvider: appIntegrityProvider
            )
        } catch let error as ProofOfPossessionError {
            // TODO: display app integrity error here
        }
    }
    
    private func handleFirebaseAppCheckError(
        _ error: FirebaseAppCheckError,
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) {
        switch error.kind {
        case .unknown,
             .generic,
             .invalidConfiguration,
             .keychainAccess,
             .notSupported:
            // TODO: display app integrity error here
        case .network:
            // This case is handled above
            break
        }
    }
    
    private func handleClientAssertionError(
        _ error: ClientAssertionError,
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) {
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
                // TODO: display app integrity error here
            }
        case .invalidPublicKey:
            // TODO: display app integrity error here
        }
    }
}
