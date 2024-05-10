import Foundation
import JWTKit
import Networking

final class JWTVerifier {
    let token: String
    let networkClient: NetworkClient
    
    init(token: String, networkClient: NetworkClient) {
        self.token = token
        self.networkClient = networkClient
    }
}

extension JWTVerifier {
    func fetchJWK() async throws -> JWKSInfo? {
        var request = URLRequest(url: AppEnvironment.jwskURL)
        request.httpMethod = "GET"

        let data = try await networkClient.makeRequest(request)
        let jwksInfo = try JSONDecoder().decode(JWKSInfo.self, from: data)
        return jwksInfo
    }
}
