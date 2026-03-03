import Foundation
import JWTKit

struct IdTokenPayload: JWTPayload {
    let persistentId: String
    let walletStoreId: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case persistentId, email
        case walletStoreId = "uk.gov.account.token/walletStoreId"
    }
    
    func verify(using signer: JWTSigner) throws { /* protocol conformance */ }
}
