import Foundation
import JWTKit

// These wrapper structs are necessary becaue JWTKit does not support encryption JWKs, and will throw
// a decoding error if one is encountered in the fetched keys.  The wrappers allows us to decode the
// JSON and extract usable keys before relying on JWTKit to do the heavy lifting.
struct JWKSInfo: Codable {
    let keys: [JWKInfo]
    
    enum CodingKeys: String, CodingKey {
        case keys
    }
    
    func jwkForKID(_ kid: String) throws -> JWK? {
        guard let jwkInfo = keys.first(where: { $0.kid == kid }),
              let json = try jwkInfo.jsonString else {
            return nil
        }
        return try JWK(json: json)
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
