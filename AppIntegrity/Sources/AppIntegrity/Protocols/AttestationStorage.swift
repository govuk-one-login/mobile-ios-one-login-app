import Foundation

public protocol AttestationStorage {
    var attestationExpired: Bool { get throws }
    var attestationJWT: String { get throws }
    
    func store(
        clientAttestation: String,
        attestationExpiry: Date
    ) throws
}
