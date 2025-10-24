// TODO: share this implementation with SecureStore?
public struct JWKs: Codable {
    public let jwk: JWK
}

/// JWK compliant with formating described in: https://datatracker.ietf.org/doc/html/rfc7517#section-4
public struct JWK: Equatable, Codable {
    let keyType: KeyType = .ec
    let intendedUse: IntendedUse = .signing
    let ellipticCurve: EllipticCurve = .primeField256Bit
    let x: String
    let y: String
    
    enum CodingKeys: String, CodingKey {
        case keyType = "kty"
        case intendedUse = "use"
        case ellipticCurve = "crv"
        case x, y
    }
    
    enum KeyType: String, Codable {
        case ec = "EC"
    }
    
    enum IntendedUse: String, Codable {
        case signing = "sig"
    }
    
    enum EllipticCurve: String, Codable {
        case primeField256Bit = "P-256"
    }
}

extension JWK {
    var dictionary: [String: String] {
        [
            CodingKeys.keyType.rawValue: keyType.rawValue,
            CodingKeys.intendedUse.rawValue: intendedUse.rawValue,
            CodingKeys.ellipticCurve.rawValue: ellipticCurve.rawValue,
            CodingKeys.x.rawValue: x,
            CodingKeys.y.rawValue: y
        ]
    }
}
