import Foundation
import JWTKit
#if NOW
@testable import OneLoginNOW
#else
@testable import OneLogin
#endif


final class MockTokenVerifier: TokenVerifier {
    var verificationError: Error?
    var extractionError: Error?
    
    func verifyToken(_ token: String) async throws -> IdTokenPayload? {
        if let verificationError {
            throw verificationError
        }
        return Self.mockPayload
    }
    
    func extractPayload(_ token: String) throws -> IdTokenPayload? {
        if let extractionError {
            throw extractionError
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
