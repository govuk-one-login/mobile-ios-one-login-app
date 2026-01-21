import Authentication
import Foundation
import Networking

enum TokenError: Error {
    case unableToDecodeServiceTokenResponse
    case bearerNotPresent
    case expired
}

final class TokenHolder {
    private let client: NetworkClient
    private var subjectToken: String? { accessToken }
    
    private(set) var idToken: String?
    private(set) var refreshToken: String?
    private(set) var accessToken: String?
    private(set) var accessTokenExpiry: Date?
    
    var isAccessTokenValid: Bool {
        guard let accessTokenExpiry else {
            return false
        }
        
        return accessTokenExpiry.withFifteenSecondBuffer > .now
    }
    
    init(client: NetworkClient = NetworkClient()) {
        self.client = client
    }

    func update(
        idToken: String? = nil,
        refreshToken: String? = nil,
        accessToken: String?,
        accessTokenExpiry: Date?
    ) {
        self.idToken = idToken
        self.refreshToken = refreshToken
        self.accessToken = accessToken
        self.accessTokenExpiry = accessTokenExpiry
    }

    func clear() {
        idToken = nil
        refreshToken = nil
        accessToken = nil
        accessTokenExpiry = nil
    }
    
    func clearAfterLogin() {
        idToken = nil
        refreshToken = nil
    }
}

extension TokenHolder: AuthorizationProvider {
    public func fetchToken(withScope scope: String) async throws -> String {
        try await exchangeToken(scope: scope).accessToken
    }

    private func exchangeToken(scope: String) async throws -> TokenResponse {
        guard let subjectToken else {
            throw TokenError.bearerNotPresent
        }
        
        let serviceTokenResponse = try await client.makeRequest(
            .serviceTokenExchange(
                subjectToken: subjectToken,
                scope: scope
            )
        )
        
        do {
            return try JSONDecoder()
                .decode(TokenResponse.self, from: serviceTokenResponse)
        } catch {
            throw TokenError.unableToDecodeServiceTokenResponse
        }
    }
}
