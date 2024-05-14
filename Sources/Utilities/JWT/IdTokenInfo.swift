import Foundation
import JWTKit

struct IdTokenInfo: JWTPayload {

    var sub: SubjectClaim
    var aud: AudienceClaim
    var iss: IssuerClaim
    var exp: ExpirationClaim
    var iat: IssuedAtClaim

    let email: String
    let emailVerified: BoolClaim
    
    func verify(using signer: JWTKit.JWTSigner) throws { /* protocol conformance */ }
}
