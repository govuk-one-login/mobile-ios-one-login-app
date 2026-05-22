import Foundation

public protocol AppIntegrityProvider {
    var clientAssertions: [String: String] { get async throws }
    var dPoPAssertion: [String: String] { get throws }
    // TODO: DCMAW-20368 Delete this
    var integrityAssertions: [String: String] { get async throws }
}
