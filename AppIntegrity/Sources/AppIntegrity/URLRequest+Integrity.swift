import Foundation

extension URLRequest {
    static func clientAttestation(baseURL: URL,
                                  token: String,
                                  body: Data) throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent("client-attestation"))
        request.httpMethod = "POST"

        request.addValue(token, forHTTPHeaderField: "X-Firebase-AppCheck")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = body

        return request
    }
}
