@testable import AppIntegrity
import Foundation

class MockAttestationStore: AttestationStorage {
    var validAttestation: Bool = false
    var attestationJWT: String = "testSavedAttestation"
    
    var mockStorage = [String: Any]()
    
    func store(assertionJWT: String, assertionExpiry: Date) {
        mockStorage["attestationJWT"] = assertionJWT
        mockStorage["attestationExpiry"] = assertionExpiry
    }
}
