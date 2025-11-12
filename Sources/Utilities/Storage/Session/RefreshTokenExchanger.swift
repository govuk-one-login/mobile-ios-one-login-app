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

struct RefreshTokenExchangeManager: TokenExchangeManaging {
    let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> TokenResponse {
        let exchangeResponse = try await networkClient.makeRequest(
            .refreshTokenExchange(
                token: refreshToken,
                appIntegrityProvider: appIntegrityProvider
            )
        )
        return try JSONDecoder()
            .decode(TokenResponse.self, from: exchangeResponse)
    }
}
