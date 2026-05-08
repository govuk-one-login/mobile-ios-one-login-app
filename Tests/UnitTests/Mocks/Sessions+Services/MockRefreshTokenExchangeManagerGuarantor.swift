import AppIntegrity
import Authentication
import Foundation
import JWTKit
@testable import OneLogin

final class MockRefreshTokenExchangeManagerGuarantor: TokenExchangeManaging {
    
    enum GetUpdatedTokensError: Error, LocalizedError, CustomStringConvertible {
        case violation(_ refreshToken: String, _ refreshTokens: Set<String>)
        
        var failureReason: String? {
            switch self {
            case let .violation(refreshToken, refreshTokens):
                return "\(refreshToken.debugDescription) already exists in: \(refreshTokens.debugDescription)"
            }
        }
        
        var description: String {
            switch self {
            case .violation:
                return "A refresh token was used twice to make a request to getUpdatedTokens. " +
                "This is a violation of the getUpdatedTokens which expects a refresh token to only be used once."
            }
        }
    }
    
    struct TokenGenerator: IteratorProtocol {
        typealias Element = String
        
        struct RefreshTokenPayload: Encodable {
            let exp: ExpirationClaim
            let nonce: UUID
        }

        static func make() -> TokenGenerator {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .custom { date, encoder in
                var container = encoder.singleValueContainer()
                try container.encode(Int(date.timeIntervalSince1970))
            }
            
            return TokenGenerator(encoder: encoder)
        }
        
        let encoder: JSONEncoder
        
        func next() -> String? {
            let refreshToken = RefreshTokenPayload(exp: ExpirationClaim(value: Date.distantFuture), nonce: UUID())
            // swiftlint:disable:next force_try
            let payload = try! encoder.encode(refreshToken).base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .trimmingCharacters(in: CharacterSet(charactersIn: "=="))

            return  "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE2ZGI2NTg3LTU0NDUtNDVkNi1hN2Q5LTk4NzgxZWJkZjkzZCJ9.\(payload)." +
                "7ocBIY_vVO83eYlYpJJJuFvl_GtWqwkeYzEDiNjSfUGGatnIW5ahcoEC-tjkIxQhVjpKhmcS_HcE34836OSXrw"
        }
    }

    private let lock = NSLock()
    private var refreshTokens = Set<String>()
    private let tokenGenerator = TokenGenerator.make()

    var capturedRefreshTokens: Set<String> {
        lock.withLock {
            refreshTokens
        }
    }

    func getUpdatedTokens(
        refreshToken: String,
        appIntegrityProvider: AppIntegrityProvider
    ) async throws -> TokenResponse {
        let inserted = lock.withLock {
            refreshTokens.insert(refreshToken).inserted
        }

        guard inserted else {
            throw GetUpdatedTokensError.violation(refreshToken, refreshTokens)
        }
        
        // 100ms to 1 second
        try await Task.sleep(nanoseconds: UInt64.random(in: 100_000_000...1_000_000_000))

        return TokenResponse(accessToken: "any",
                             refreshToken: tokenGenerator.next(),
                             idToken: "any",
                             tokenType: "token",
                             expiryDate: Date().addingTimeInterval(-3600))
    }
}
