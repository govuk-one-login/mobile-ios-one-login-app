import Foundation

public protocol AttestationStorage {
    var validAttestation: Bool { get throws }
    var attestationJWT: String { get throws }
    
    func store(
        clientAttestation: String,
        attestationExpiry: String
    ) throws
}
