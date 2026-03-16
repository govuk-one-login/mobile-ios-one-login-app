import AppIntegrity
@testable import Authentication
import Foundation
@testable import OneLogin

final class MockRefreshTokenExchangeManager: TokenExchangeManaging {
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> TokenResponse {
        return TokenResponse(
            accessToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            tokenType: "token_type",
            expiryDate: Date.distantFuture
        )
    }
}

final class MockRefreshTokenNilExchangeManager: TokenExchangeManaging {
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> TokenResponse {
        return TokenResponse(
            accessToken: MockJWTs.genericToken,
            refreshToken: nil,
            tokenType: "token_type",
            expiryDate: Date.distantFuture
        )
    }
}
