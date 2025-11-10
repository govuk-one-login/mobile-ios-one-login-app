import AppIntegrity
import Foundation
import Networking

protocol TokenExchangeManaging {
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> StoredTokens
}

struct RefreshTokenExchangeManager: TokenExchangeManaging {
    let networkClient: NetworkClient
    
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> StoredTokens {
        let refreshTokenResponse = try await networkClient.makeRequest(.refreshExchange(
            token: refreshToken,
            appIntegrityProvider: appIntegrityProvider
        ))
        return try JSONDecoder().decode(StoredTokens.self, from: refreshTokenResponse)
    }
}
