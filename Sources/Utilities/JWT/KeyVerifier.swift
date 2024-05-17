import Foundation
import JWTKit

protocol KeyVerifier {
    func verify(jwt: String) throws -> IdTokenInfo
}

struct ES256KeyVerifier: KeyVerifier {
    let signers = JWTSigners(defaultJSONEncoder: .oneLoginJWTEncoder,
                             defaultJSONDecoder: .oneLoginJWTDecoder)
    
    init(jsonWebKey: JWK) throws {
        try signers.use(jwk: jsonWebKey)
    }
    
    func verify(jwt: String) throws -> IdTokenInfo {
        try signers.verify(jwt)
    }
}

extension JWTJSONDecoder where Self == JSONDecoder {
    static var oneLoginJWTDecoder: any JWTJSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

extension JWTJSONEncoder where Self == JSONEncoder {
    static var oneLoginJWTEncoder: any JWTJSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}