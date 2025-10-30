import JWTKit

struct RefreshTokenPayload: JWTPayload {
    let exp: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws { /* protocol conformance */ }
}
