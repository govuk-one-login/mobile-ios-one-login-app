import AppIntegrity
@testable import Authentication
import Foundation
@testable import OneLogin

final class MockRefreshTokenExchangeManager: TokenExchangeManaging {
    var errorFromGetUpdatedTokens: Error?
    
    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> TokenResponse {
        if let errorFromGetUpdatedTokens {
            throw errorFromGetUpdatedTokens
        }
        
        return TokenResponse(
            accessToken: MockJWTs.genericToken,
            refreshToken: MockJWTs.genericToken,
            tokenType: "token_type",
            expiryDate: Date.distantFuture
        )
    }
}
