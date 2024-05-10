import Foundation
import JWTKit

struct UserCredential: JWTPayload {

    var sub: SubjectClaim

    var exp: Int

    let email: String
    let email_verified: BoolClaim
    
    func verify(using signer: JWTKit.JWTSigner) throws { /* protocol conformance */ }
}

// These wrapper structs are necessary becaue JWTKit does not support encryption JWKs, and will throw
// a decoding error if one is encountered in the fetched keys.  The wrappers allows us to decode the
// JSON and extract usable keys before relying on JWTKit to do the heavy lifting.
struct JWKSInfo: Codable {
    let keys: [JWKInfo]
    
    enum CodingKeys: String, CodingKey {
        case keys
    }
    
    var signingJWK: JWK? {
        get throws {
            guard let signingJWKInfo = self.keys.first(where: { $0.use == "sig" }) else { return nil }
            guard let json = try signingJWKInfo.jsonString else { return nil }
            return try JWK(json: json)
        }
    }
}

struct JWKInfo: Codable {
    let kty: String
    let alg: String
    let kid: String
    let n: String?
    let e: String?
    let use: String
    let crv: String?
    let x: String?
    let y: String?
    
    enum CodingKeys: String, CodingKey {
        case kty
        case alg
        case kid
        case n
        case e
        case use
        case crv
        case x
        case y
    }
    
    var jsonString: String? {
        get throws {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)
        }
    }
}
