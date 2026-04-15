import AppIntegrity
@testable import Authentication
import Foundation
@testable import OneLogin
import Testing

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

final class MockRefreshTokenExchangeManagerConfirmation: TokenExchangeManaging {
    
    let tokenExchangeManaging = MockRefreshTokenExchangeManager()
    let confirmation: Confirmation
    
    init(confirmation: Confirmation) {
        self.confirmation = confirmation
    }
    
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> TokenResponse {
        defer {
            confirmation()
        }
        return try await tokenExchangeManaging.getUpdatedTokens(refreshToken: refreshToken, appIntegrityProvider: appIntegrityProvider)
    }
}
