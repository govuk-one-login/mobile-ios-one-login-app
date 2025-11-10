import AppIntegrity

protocol TokenExchangeManaging {
    func getUpdatedTokens(
        refreshToken: String?,
        integrityHeaders: AppIntegrityProvider
    ) async throws
}

struct RefreshTokenExchangeManager: TokenExchangeManaging {
    func getUpdatedTokens(
        refreshToken: String?,
        integrityHeaders: AppIntegrityProvider
    ) async throws {
        <#code#>
    }
}
