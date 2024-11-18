import Foundation

public protocol AppIntegrityProvider {
    func assertIntegrity() async throws -> [String: Any]
}
