import AppIntegrity
import Foundation

extension URLRequest {
    static func refreshTokenExchange(
        token: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> Self {
        var request = URLRequest(url: AppEnvironment.stsToken)
        
        request.asXWWWFormURLEncoded()
        
        for (key, value) in try await appIntegrityProvider.integrityAssertions {
            request.setValue(
                value,
                forHTTPHeaderField: key
            )
        }
        
        request.httpBody = makeRefreshTokenExchangeQueryString(for: token)?.data(using: .utf8)
        
        return request
    }
    
    static func serviceTokenExchange(
        subjectToken: String,
        scope: String
    ) -> Self {
        var request = URLRequest(url: AppEnvironment.stsToken)
        
        request.asXWWWFormURLEncoded()
        
        request.httpBody = makeServiceTokenQueryString(
            subjectToken: subjectToken,
            scope: scope
        )?.data(using: .utf8)
        
        return request
    }
    
    private mutating func asXWWWFormURLEncoded() {
        self.httpMethod = "POST"
        
        self.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )
    }
    
    private static func makeRefreshTokenExchangeQueryString(for token: String) -> String? {
        var urlComponents = URLComponents()
        
        urlComponents.queryItems = [
            .grantType(.refreshToken),
            .refreshToken(token)
        ]
        
        return urlComponents.percentEncodedQuery
    }
    
    private static func makeServiceTokenQueryString(subjectToken: String, scope: String) -> String? {
        var urlComponents = URLComponents()
        
        urlComponents.queryItems = [
            .subjectTokenType,
            .grantType(.tokenExchange),
            .subjectToken(subjectToken),
            .scope(scope)
        ]
        
        return urlComponents.percentEncodedQuery
    }
}

extension URLQueryItem {
    enum GrantType: String {
        case refreshToken = "refresh_token"
        case tokenExchange = "urn:ietf:params:oauth:grant-type:token-exchange"
    }
    
    static func grantType(_ grantType: GrantType) -> Self {
        URLQueryItem(
            name: "grant_type",
            value: grantType.rawValue
        )
    }
    
    static func refreshToken(_ token: String) -> Self {
        URLQueryItem(
            name: "refresh_token",
            value: token
        )
    }
    
    static var subjectTokenType: Self {
        URLQueryItem(
            name: "subject_token_type",
            value: "urn:ietf:params:oauth:token-type:access_token"
        )
    }
    
    static func subjectToken(_ token: String) -> Self {
        URLQueryItem(
            name: "subject_token",
            value: token
        )
    }
    
    static func scope(_ scope: String) -> Self {
        URLQueryItem(
            name: "scope",
            value: scope
        )
    }
}
