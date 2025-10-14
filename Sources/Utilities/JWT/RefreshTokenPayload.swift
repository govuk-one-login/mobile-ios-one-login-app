import Foundation
import JWTKit

struct RefreshTokenPayload: JWTPayload {
    let exp: ExpirationClaim
    
    func verify(using signer: JWTKit.JWTSigner) throws { /* protocol conformance */ }
}
