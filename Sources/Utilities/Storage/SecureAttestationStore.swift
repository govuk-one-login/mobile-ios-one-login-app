import AppIntegrity
import Foundation
import SecureStore

enum AttestationStorageKey: String {
    case clientAttestationJWT
    case attestationExpiry
}

enum AttestationStorageError: Error {
    case cantRetrieveAttestationJWT
}

final class SecureAttestationStore: AttestationStorage {
    private let secureStore: SecureStorable
    
    var attestationExpired: Bool {
        guard let expriyDate = try? secureStore
            .readDate(id: AttestationStorageKey.attestationExpiry.rawValue) else {
            return true
        }
        return expriyDate < .now
    }
    
    var attestationJWT: String {
        get throws {
            try secureStore.readItem(itemName: AttestationStorageKey.clientAttestationJWT.rawValue)
        }
    }
    
    func store(
        clientAttestation: String,
        attestationExpiry: Date
    ) throws {
        try secureStore.saveItem(
            item: clientAttestation,
            itemName: AttestationStorageKey.clientAttestationJWT.rawValue
        )
        try secureStore.saveDate(
            id: AttestationStorageKey.attestationExpiry.rawValue,
            attestationExpiry
        )
    }
    
    init(
        secureStore: SecureStorable = SecureStoreService(
            configuration: SecureStorageConfiguration(
                id: OLString.attestationStore,
                accessControlLevel: .open
            )
        )
    ) {
        self.secureStore = secureStore
    }
}
