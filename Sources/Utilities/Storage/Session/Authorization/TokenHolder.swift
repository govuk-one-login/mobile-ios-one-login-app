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

    private func exchangeToken(scope: String) async throws -> ServiceTokenResponse {
        guard let subjectToken else {
            throw TokenError.bearerNotPresent
        }
        let serviceTokenRequest = URLRequest.tokenExchange(
            subjectToken: subjectToken,
            scope: scope
        )
        let serviceTokenResponse = try await client.makeRequest(serviceTokenRequest)
        return try decodeServiceToken(data: serviceTokenResponse)
    }

    private func decodeServiceToken(data: Data) throws -> ServiceTokenResponse {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try jsonDecoder.decode(ServiceTokenResponse.self, from: data)
        } catch {
            throw TokenError.unableToDecodeServiceTokenResponse
        }
    }
}
