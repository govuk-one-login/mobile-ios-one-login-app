import Foundation

public protocol AttestationStorage {
    var validAttestation: Bool { get }
    var attestationJWT: String { get throws }
    func store(
        assertionJWT: String,
        assertionExpiry: Date
    )
}
