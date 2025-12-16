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
    
    private(set) var errorRetries = 0
    
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
        } catch let error as ServerError where error.errorCode == 400 {
            NotificationCenter.default.post(name: .accountIntervention)
            throw RefreshTokenExchangeError.accountIntervention
        } catch let error as FirebaseAppCheckError where error.errorType == .network {
            throw RefreshTokenExchangeError.noInternet
        } catch let error as URLError where error.code == .notConnectedToInternet
                    || error.code == .networkConnectionLost {
            throw RefreshTokenExchangeError.noInternet
        } catch {
            throw error
        }
    }
}
    
