import Foundation
import JWTKit

protocol KeyVerifier {
    func verify(jwt: String) throws -> IdTokenInfo
}

struct ES256KeyVerifier: KeyVerifier {
    let signers = JWTSigners()
    
    init(jsonWebKey: JWK) throws {
        try signers.use(jwk: jsonWebKey)
    }
    
    func verify(jwt: String) throws -> IdTokenInfo {
        try signers.verify(jwt)
    }
}
