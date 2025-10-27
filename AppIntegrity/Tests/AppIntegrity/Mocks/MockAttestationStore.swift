@testable import AppIntegrity
import Foundation

class MockAttestationStore: AttestationStorage {
    var attestationExpired: Bool = true
    
    var attestationJWT: String = "testSavedAttestation"
    
    var mockStorage = [String: Any]()
    
    func store(
        clientAttestation assertionJWT: String,
        attestationExpiry assertionExpiry: Date
    ) {
        mockStorage["attestationJWT"] = assertionJWT
        mockStorage["attestationExpiry"] = assertionExpiry
    }
}
