import Foundation
import JWTKit
import Networking

final class JWTVerifier {
    let token: String
    let networkClient: NetworkClient
    
    init(token: String, networkClient: NetworkClient = NetworkClient()) {
        self.token = token
        self.networkClient = networkClient
    }
}

extension JWTVerifier {
    func verifyCredential() async throws -> IdTokenPayload? {
        let jwksInfo = try await fetchJWKs()
        
        guard let kid = try extractKIDFromHeader(),
              let jwk = try jwksInfo.jwkForKID(kid) else {
            throw JWTVerifierError.invalidKID
        }
        
        let verifier = try ES256KeyVerifier(jsonWebKey: jwk)
        
        return try verifier.verify(jwt: token)
    }
}

extension JWTVerifier {
    private func fetchJWKs() async throws -> JWKSInfo {
        var request = URLRequest(url: AppEnvironment.jwskURL)
        request.httpMethod = "GET"

        do {
            let data = try await networkClient.makeRequest(request)
            let jwksInfo = try JSONDecoder().decode(JWKSInfo.self, from: data)
            return jwksInfo
        } catch {
            throw JWTVerifierError.unableToFetchJWKs
        }
    }

    private func extractKIDFromHeader() throws -> String? {
        let parts = try getPartsOfJWT()
        
        let payloadPaddingString = base64StringWithPadding(encodedString: parts[0])
        guard let payloadData = Data(base64Encoded: payloadPaddingString) else { return nil }
            
        let header = try JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any]
        let kid = header?["kid"] as? String
        return kid
    }
    
    private func getPartsOfJWT() throws -> [String] {
        let parts = token.components(separatedBy: ".")
        if parts.count != 3 {
            throw JWTVerifierError.invalidJWTFormat
        }
        return parts
    }
    
    private func base64StringWithPadding(encodedString: String) -> String {
        var stringTobeEncoded = encodedString.replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let paddingCount = encodedString.count % 4
        for _ in 0..<paddingCount {
            stringTobeEncoded += "="
        }
        return stringTobeEncoded
    }
}
