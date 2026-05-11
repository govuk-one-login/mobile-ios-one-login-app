import AppIntegrity
import Authentication
import Foundation
import JWTKit
@testable import OneLogin

/// A mock that strictly adheres to the contract of the ``TokenExchangeManaging/getUpdatedTokens(refreshToken:appIntegrityProvider:)`` endpoint.
///
/// Specifically, this mock:
/// * Throws an error in case the **same** `refreshToken` is passed to ``getUpdatedTokens(refreshToken:appIntegrityProvider:)``, which
/// is a violation of the expectation to only ever use a refresh token once.
/// * Generates a **valid**, **unique** refresh token every time a request is made
/// * Adds a **random delay** before returning a token response to emulate the variability and delay of a network response
///
/// Use this mock to write a test that will fail **should the code under test violates any of the conditions as expected by the endpoint**, in adition to the test assertions.
///
/// e.g. you want to ensure that your code:
/// * Does not send **the same refresh token more than once**.
/// * Expects **unique** refresh tokens
///
/// - SeeAlso: ``NetworkingServiceTests/test_makeAuthorisedRequest_invalidAccessToken_concurrent()``
/// - SeeAlso  ``NetworkingServiceTests/test_makeAuthorisedRequest_invalidAccessToken_concurrent_with_sessionManager()``
/// - SeeAlso  ``PersistentSessionManagerTests/test_refreshTokenExchange_isSerialisedAcrossResumeSessionAndAuthorizedRequest()``
/// - Remark: This mock is not designed to be used by a test that wants to stub a response. Use a ``MockRefreshTokenExchangeManager`` instead.
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
