import AppIntegrity
import Foundation

extension URLRequest {
    static func refreshTokenExchange(
        token: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> Self {
        var request = URLRequest(url: AppEnvironment.stsToken)
        
        request.httpMethod = "POST"
        
        request.allHTTPHeaderFields = try await appIntegrityProvider.integrityAssertions
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var urlParser = URLComponents()
        urlParser.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: token)
        ]
        request.httpBody = urlParser.percentEncodedQuery?.data(using: .utf8)
        
        return request
    }
    
    static func serviceTokenExchange(
        subjectToken: String,
        scope: String
    ) -> Self {
        var request = URLRequest(url: AppEnvironment.stsToken)
        
        request.httpMethod = "POST"
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var urlParser = URLComponents()
        urlParser.queryItems = [
            URLQueryItem(name: "subject_token_type", value: "urn:ietf:params:oauth:token-type:access_token"),
            URLQueryItem(name: "grant_type", value: "urn:ietf:params:oauth:grant-type:token-exchange"),
            URLQueryItem(name: "subject_token", value: subjectToken),
            URLQueryItem(name: "scope", value: scope)
        ]
        request.httpBody = urlParser.percentEncodedQuery?.data(using: .utf8)
        
        return request
    }
}
