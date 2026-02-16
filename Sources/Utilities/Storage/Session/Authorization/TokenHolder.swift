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
}

extension TokenHolder: AuthorizationProvider {
    public func fetchToken(withScope scope: String) async throws -> String {
        try await exchangeToken(scope: scope).accessToken
    }

    private func exchangeToken(scope: String) async throws -> TokenResponse {
        guard let accessToken else {
            throw TokenError.bearerNotPresent
        }
        
        let serviceTokenResponse: Data
        
        do {
            serviceTokenResponse = try await client.makeRequest(
                .serviceTokenExchange(
                    subjectToken: accessToken,
                    scope: scope
                )
            )
        } catch let error as ServerError where error.errorCode == 400 {
            handleServerError(error)
            throw error
        }
        
        do {
            return try JSONDecoder()
                .decode(TokenResponse.self, from: serviceTokenResponse)
        } catch {
            throw TokenError.unableToDecodeServiceTokenResponse
        }
    }
    
    private func handleServerError(_ error: ServerError) {
        guard let data = error.response,
              let errorType = try? JSONDecoder().decode(ServerErrorResponse.self, from: data),
              errorType.error == .invalidGrant else {
            // Build environment throws 400 invalid_target so we shouldn't log the user out in that case
            return
        }
        NotificationCenter.default.post(name: .accountIntervention)
    }
}
