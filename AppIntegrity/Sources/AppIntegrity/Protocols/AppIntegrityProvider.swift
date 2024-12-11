import Foundation

public protocol AppIntegrityProvider {
    var proofTokenGenerator: ProofTokenGenerator { get }
    func assertIntegrity() async throws -> [String: String]
}
