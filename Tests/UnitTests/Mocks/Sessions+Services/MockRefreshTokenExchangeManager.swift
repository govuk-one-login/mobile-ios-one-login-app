import AppIntegrity
@testable import Authentication
import Foundation
@testable import OneLogin

struct MockRefreshTokenExchangeManager: TokenExchangeManaging {
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> TokenResponse {
        return  TokenResponse(accessToken: "access_token",
                              refreshToken: "refresh_token",
                              tokenType: "token_type",
                              expiryDate: Date.distantFuture)
    }
}
