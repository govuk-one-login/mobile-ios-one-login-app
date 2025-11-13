import AppIntegrity
@testable import Authentication
import Foundation
@testable import OneLogin

struct MockRefreshTokenExchangeManager: TokenExchangeManaging {
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> TokenResponse {
        TokenResponse(
            accessToken: "testAccessToken",
            refreshToken: "testRefreshToken",
            tokenType: "token_type",
            expiryDate: Date.distantFuture
        )
    }
}
