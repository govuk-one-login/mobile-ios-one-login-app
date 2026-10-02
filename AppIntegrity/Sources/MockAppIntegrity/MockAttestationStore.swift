import AppIntegrity
import Foundation

public final class MockAttestationStore: AttestationStorage {
    public var mockStorage: [String: Any]

    public var attestationExpired: Bool
    public var attestationJWT: String
        
    public init(mockStorage: [String: Any] = [String: Any](), attestationExpired: Bool = true, attestationJWT: String = "testSavedAttestation") {
        self.mockStorage = mockStorage
        self.attestationExpired = attestationExpired
        self.attestationJWT = attestationJWT
    }
    
    public func store(
        clientAttestation assertionJWT: String,
        attestationExpiry assertionExpiry: Date
    ) {
        mockStorage["attestationJWT"] = assertionJWT
        mockStorage["attestationExpiry"] = assertionExpiry
    }
}
