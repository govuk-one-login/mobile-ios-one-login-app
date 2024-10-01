import Foundation

extension URLRequest {
    static func clientAttestation(token: String) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "app-integrity-spike.mobile.dev.account.gov.uk"
        components.path = "/client-attestation"
        components.queryItems = [URLQueryItem(name: "device", value: "ios")]

        let encoder = JSONEncoder()

        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.httpBody = try encoder.encode(ClientAssertionRequest(jwk: token))
        request.addValue(token, forHTTPHeaderField: "X-Firebase-AppCheck")
        return request
    }
}
