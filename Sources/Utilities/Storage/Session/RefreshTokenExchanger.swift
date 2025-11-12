import AppIntegrity
import Authentication
import Foundation
import Networking

protocol TokenExchangeManaging {
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> RefreshTokenExchangeResponse
}

struct RefreshTokenExchangeManager: TokenExchangeManaging {
    let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> RefreshTokenExchangeResponse {
        let exhcnageResponse = try await networkClient.makeRequest(
            .refreshTokenExchange(
                token: refreshToken,
                appIntegrityProvider: appIntegrityProvider
            )
        )
        return try JSONDecoder()
            .decode(RefreshTokenExchangeResponse.self, from: exhcnageResponse)
    }
}
