import Foundation
import JWTKit

struct IdTokenPayload: JWTPayload {
    let persistentId: String
    let email: String
    
    func verify(using signer: JWTKit.JWTSigner) throws { /* protocol conformance */ }
}
