import Foundation
import JWTKit
@testable import OneLogin

final class MockTokenVerifier: TokenVerifier {
    var verificationFailed = false
    var extractionFailed = false
    
    func verifyToken(_ token: String) async throws -> IdTokenPayload? {
        if verificationFailed {
            throw JWTVerifierError.invalidJWTFormat
        }
        return Self.mockPayload
    }
    
    func extractPayload(_ token: String) throws -> IdTokenPayload? {
        if extractionFailed {
            throw JWTVerifierError.invalidJWTFormat
        }
        return Self.mockPayload
    }
}

extension MockTokenVerifier {
    static let mockPayload = IdTokenPayload(sub: "subject",
                                            aud: "audience",
                                            iss: "issuer",
                                            exp: .init(value: Date()),
                                            iat: .init(value: Date()),
                                            email: "mock@email.com",
                                            emailVerified: true)
}
