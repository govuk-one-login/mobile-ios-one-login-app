import Authentication
import Foundation
import Networking

enum TokenError: Error {
    case unableToDecodeServiceTokenResponse
    case bearerNotPresent
    case expired
}

final class TokenHolder {
    let client: NetworkClient
    private(set) var subjectToken: String?

    init(client: NetworkClient = NetworkClient()) {
        self.client = client
    }

    func update(subjectToken: String) {
        self.subjectToken = subjectToken
    }

    func clear() {
        subjectToken = nil
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
