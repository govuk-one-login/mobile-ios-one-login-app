import Foundation

extension URLRequest {
    static func tokenExchange(subjectToken: String, scope: String) -> Self {
        var request = URLRequest(url: AppEnvironment.stsToken)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var urlParser = URLComponents()
        urlParser.queryItems = [
            URLQueryItem(name: "grant_type", value: "urn:ietf:params:oauth:grant-type:token-exchange"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "subject_token", value: subjectToken),
            URLQueryItem(name: "subject_token_type", value: "urn:ietf:params:oauth:token-type:access_token")
        ]
        request.httpBody = urlParser.percentEncodedQuery?.data(using: .utf8)
        return request
    }
}
