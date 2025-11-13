import AppIntegrity
@testable import Authentication
import Foundation
@testable import OneLogin

final class MockRefreshTokenExchangeManager: TokenExchangeManaging {
    var errorFromRefreshTokenExchange: Error?
    
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> TokenResponse {
        if let errorFromRefreshTokenExchange {
            throw errorFromRefreshTokenExchange
        } else {
            TokenResponse(
                accessToken: "testAccessToken",
                refreshToken: "testRefreshToken",
                tokenType: "token_type",
                expiryDate: Date.distantFuture
            )
        }
    }
}
