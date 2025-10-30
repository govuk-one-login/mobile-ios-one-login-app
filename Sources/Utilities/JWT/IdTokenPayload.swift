import Foundation
import JWTKit

struct IdTokenPayload: JWTPayload {
    let persistentId: String
    let email: String
    
    func verify(using signer: JWTSigner) throws { /* protocol conformance */ }
}
