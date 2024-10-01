import Foundation

extension URLRequest {
    static func clientAttestation(baseURL: URL, token: String) throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent("client-attestation"))
        request.httpMethod = "POST"

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(ClientAssertionRequest(jwk: token))
        
        request.addValue(token, forHTTPHeaderField: "X-Firebase-AppCheck")
        return request
    }
}
