import Foundation

extension URLRequest {
    static func assert(token: String) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "app-integrity-spike.mobile.dev.account.gov.uk"
        components.path = "/client-attestation"
        components.queryItems = [URLQueryItem(name: "device", value: "ios")]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.httpBody = Data(token.utf8)
        return request
    }
}
