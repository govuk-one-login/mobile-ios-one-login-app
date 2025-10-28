@testable import AppIntegrity
import Foundation

class MockAttestationStore: AttestationStorage {
    var mockStorage = [String: Any]()

    var attestationExpired: Bool = true
    var attestationJWT: String = "testSavedAttestation"
        
    func store(
        clientAttestation assertionJWT: String,
        attestationExpiry assertionExpiry: Date
    ) {
        mockStorage["attestationJWT"] = assertionJWT
        mockStorage["attestationExpiry"] = assertionExpiry
    }
}
