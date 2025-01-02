import Foundation

public protocol AppIntegrityProvider {
    var integrityAssertions: [String: String] { get async throws }
}
