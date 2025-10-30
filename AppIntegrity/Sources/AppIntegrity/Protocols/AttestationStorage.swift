import Foundation

public protocol AttestationStorage {
    var attestationExpired: Bool { get }
    var attestationJWT: String { get throws }
    
    func store(
        clientAttestation: String,
        attestationExpiry: Date
    ) throws
}
