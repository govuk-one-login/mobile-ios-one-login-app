import Foundation

public protocol AppIntegrityProvider {
    var clientAssertions: [String: String] { get async throws }
    var dPoPAssertion: [String: String] { get throws }
    
    var hasExpiredAttestation: Bool { get }
}
