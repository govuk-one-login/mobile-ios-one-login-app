import Foundation
import JWTKit

struct IdTokenPayload: JWTPayload {
    let sub: SubjectClaim
    let aud: AudienceClaim
    let iss: IssuerClaim
    let exp: ExpirationClaim
    let iat: IssuedAtClaim
    let persistentId: String

    let email: String
    let emailVerified: BoolClaim
    
    func verify(using signer: JWTKit.JWTSigner) throws { /* protocol conformance */ }
}
