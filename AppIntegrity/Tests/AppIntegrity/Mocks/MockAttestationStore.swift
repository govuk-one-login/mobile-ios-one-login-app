@testable import AppIntegrity
import Foundation

class MockAttestationStore: AttestationStorage {
    var validAttestation: Bool?
    var attestationJWT: String
    
    var mockStorage = [String: Any]()
    
    init(attestationJWT: String) {
        self.attestationJWT = attestationJWT
    }
    
    func store(assertionJWT: String, assertionExpiry: Date) {
        mockStorage[AttestationStorageKey.attestationJWT.rawValue] = assertionJWT
        mockStorage[AttestationStorageKey.attestationExpiry.rawValue] = assertionExpiry
    }
}
