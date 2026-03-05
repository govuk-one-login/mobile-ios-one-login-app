import Foundation
import JWTKit
import MockNetworking
@testable import Networking
@testable import OneLogin
import Testing

extension JWTError: @retroactive Equatable {
    public static func == (lhs: JWTError, rhs: JWTError) -> Bool {
        switch (lhs, rhs) {
        case (.claimVerificationFailure(_, _), .claimVerificationFailure(_, _)):
            return true
        case (.signingAlgorithmFailure(_), signingAlgorithmFailure(_)):
            return true
        case (.malformedToken, .malformedToken):
            return true
        case (.signatureVerifictionFailed, .signatureVerifictionFailed):
            return true
        case (.missingKIDHeader, .missingKIDHeader):
            return true
        case (.unknownKID(_), unknownKID(_)):
            return true
        case (.invalidJWK, .invalidJWK):
            return true
        case (.invalidBool(_), .invalidBool(_)):
            return true
        case (.generic(_, _), .generic(_, _)):
            return true
        default:
            return false
        }
    }
}

struct ES256KeyVerifierTests {
    private func makeJWK() throws -> JWK {
        let kid = "16db6587-5445-45d6-a7d9-98781ebdf93d"
        let keys: String = """
        {
            "keys":
            [
                {
                    "kty": "EC",
                    "x": "nfKPgSUMcrJ96ejGHr-tAvfzZOgLuFK-W_pz3Jjcs-Y",
                    "y": "Z7xBQNM9ipvaDp1Lp3DNAn7RWQ_JaUBXstcXnefLR5k",
                    "crv": "P-256",
                    "use": "sig",
                    "alg": "ES256",
                    "kid": "\(kid)"
                }
            ]
        }
        """
        
        let jwksInfo = try JSONDecoder().decode(JWKSInfo.self, from: keys.data(using: .utf8)!)
        
        guard let jwk = try jwksInfo.jwkForKID(kid) else {
            throw JWTVerifierError.invalidKID
        }
        
        return jwk
    }
    
    @Test("All cases of jwts with an bad signature for a key where kid is '16db6587-5445-45d6-a7d9-98781ebdf93d'",
          arguments: [MockJWTs.tokenWithInvalidSignature, MockJWTs.tokenMissingSignature, MockJWTs.tokenWithNoneAlgorithm])
    func verifyRequiredSignature(jwt: String) async throws {
        let jwk = try makeJWK()
        let verifier = try ES256KeyVerifier(jsonWebKey: jwk)
        
        #expect(throws: JWTError.signatureVerifictionFailed) {
            let _: IdTokenPayload = try verifier.verify(jwt: jwt)
        }
    }
}
