import Foundation
import JWTKit

protocol TokenVerifier {
    func verifyToken<TokenPayload: JWTPayload>(_ token: String) async throws -> TokenPayload
    func extractPayload<TokenPayload: JWTPayload>(_ token: String) throws -> TokenPayload
}
