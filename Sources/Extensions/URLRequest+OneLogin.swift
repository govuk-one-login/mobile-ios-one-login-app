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
        
        request.httpBody = TokenQueryItem
            .makeRefreshTokenExchangeQueryString(for: token)?.data(using: .utf8)
        
        return request
    }
    
    static func serviceTokenExchange(
        subjectToken: String,
        scope: String
    ) -> Self {
        var request = URLRequest(url: AppEnvironment.stsToken)
        
        request.asXWWWFormURLEncoded()
        
        request.httpBody = TokenQueryItem.makeServiceTokenQueryString(
            subjectToken: subjectToken,
            scope: scope
        )?.data(using: .utf8)
        
        return request
    }
    
    mutating func asXWWWFormURLEncoded() {
        self.httpMethod = "POST"
        
        self.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )
    }
}

enum TokenQueryItem {
    case grantTypeRefreshToken
    case refresh(token: String)
    case subjectTokenType
    case grantTypeTokenExchange
    case subject(token: String)
    case scope(String)
    
    var queryItem: URLQueryItem {
        switch self {
        case .grantTypeRefreshToken:
            URLQueryItem(
                name: "grant_type",
                value: "refresh_token"
            )
        case .refresh(token: let token):
            URLQueryItem(
                name: "refresh_token",
                value: token
            )
        case .subjectTokenType:
            URLQueryItem(
                name: "subject_token_type",
                value: "urn:ietf:params:oauth:token-type:access_token"
            )
        case .grantTypeTokenExchange:
            URLQueryItem(
                name: "grant_type",
                value: "urn:ietf:params:oauth:grant-type:token-exchange"
            )
        case .subject(token: let token):
            URLQueryItem(
                name: "subject_token",
                value: token
            )
        case .scope(let scope):
            URLQueryItem(
                name: "scope",
                value: scope
            )
        }
    }
    
    static func makeRefreshTokenExchangeQueryString(for token: String) -> String? {
        var urlComponents = URLComponents()
        
        urlComponents.queryItems = [
            TokenQueryItem.grantTypeRefreshToken,
            TokenQueryItem.refresh(token: token)
        ].map(\.queryItem)
        
        return urlComponents.percentEncodedQuery
    }
    
    static func makeServiceTokenQueryString(subjectToken: String, scope: String) -> String? {
        var urlComponents = URLComponents()
        
        urlComponents.queryItems = [
            TokenQueryItem.subjectTokenType,
            TokenQueryItem.grantTypeTokenExchange,
            TokenQueryItem.subject(token: subjectToken),
            TokenQueryItem.scope(scope)
        ].map(\.queryItem)
        
        return urlComponents.percentEncodedQuery
    }
}
