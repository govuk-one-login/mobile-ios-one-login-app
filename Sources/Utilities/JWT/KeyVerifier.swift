import Foundation
import JWTKit

protocol KeyVerifier {
    func verify(jwt: String) throws -> IdTokenPayload
}

struct ES256KeyVerifier: KeyVerifier {
    let signers = JWTSigners(defaultJSONEncoder: .oneLoginJWTEncoder,
                             defaultJSONDecoder: .oneLoginJWTDecoder)
        
    init(jsonWebKey: JWK? = nil) throws {
        if let jsonWebKey {
            try signers.use(jwk: jsonWebKey)
        }
    }
    
    func verify(jwt: String) throws -> IdTokenPayload {
        try signers.verify(jwt)
    }
    
    func extract(jwt: String) throws -> IdTokenPayload {
        return try signers.unverified(jwt)
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
