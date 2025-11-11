import AppIntegrity
import Foundation

enum RefreshExchangeError: Error {
    case cantExtractAppIntegrityHeaders
}

extension URLRequest {
    static func refreshExchange(
        token: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> URLRequest {
        var request = URLRequest(url: AppEnvironment.stsToken)
        request.httpMethod = "POST"
        
        var headers = try await appIntegrityProvider.integrityAssertions
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        
        request.allHTTPHeaderFields = headers
        
        request.httpBody = Data(base64URLEncoded: "grant_type=refresh_token&refresh_token=\(token)")

        return request
    }
}
