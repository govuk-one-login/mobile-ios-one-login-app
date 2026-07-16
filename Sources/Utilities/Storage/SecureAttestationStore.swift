import AppIntegrity
import Foundation
import SecureStore

enum AttestationStorageKey: String, CaseIterable {
    case clientAttestationJWT
    case attestationExpiry
}

enum AttestationStorageError: Error {
    case cantRetrieveAttestationJWT
}

/// Use a ``SecureAttestationStore`` to store the ``attestationJWT`` and ``attestationExpired`` date.
///
/// The ``SecureAttestationStore`` guarantees that data is stored securely (i.e. encrypted) and is only accessible (i.e. decrypted) when requested.
///
/// - SeeAlso: ``SecureStorable``
final class SecureAttestationStore: AttestationStorage {
    
    /// Returns a new ``SecureAttestationStore`` with the given `secureStore`.
    /// The ``SecureAttestationStore`` instance guarantees that any existing data stored in the given `secureStore`  is accessible.
    ///
    /// In case the ``attestationJWT`` in the given ``secureStore`` is not accessible (i.e. cannot be decrypted),
    /// the returned instance will **delete** all data associated with the underlying `secureStore`
    ///
    /// - parameter secureStore: an instance of the ``SecureStorable``;  by **default** the secure store is created  using a
    ///     ``SecureStorageConfiguration`` with an `id` of ``OLString/attestationStore`` and ``accessControlLevel`` that is ``AccessControlLevel/open``
    /// - SeeAlso: ``SecureStoreService/readItem``
    public static func make(secureStore: SecureStorable = SecureStoreService(
        configuration: SecureStorageConfiguration(
            id: OLString.attestationStore,
            accessControlLevel: .open
        )
    )) -> SecureAttestationStore {
        
        let secureAttestationStore = SecureAttestationStore(secureStore: secureStore)
        
        let attestationJWT = Result {
            try secureAttestationStore.attestationJWT
        }
        
        if case .failure(let error as SecureStoreError) = attestationJWT, error.kind == .cantDecryptData,
            let originalError = error.originalError as? NSError, originalError.code == errSecParam {
                secureAttestationStore.removeAllData()
        }
        
        return secureAttestationStore
    }
    
    private let secureStore: SecureStorable
    
    var attestationExpired: Bool {
        guard let expiryDate = try? secureStore
            .readDate(id: AttestationStorageKey.attestationExpiry.rawValue) else {
            return true
        }
        return expiryDate < .now
    }
    
    /// Returns the `attestationJWT` or throws an error in case that:
    /// * no `attestationJWT` is present
    /// * the `attestationJWT` cannot be decrypted
    var attestationJWT: String {
        get throws {
            try secureStore.readItem(itemName: AttestationStorageKey.clientAttestationJWT.rawValue)
        }
    }
    
    /// Creates a new ``SecureAttestationStore`` with the given `secureStore`.
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
    
    func removeAllData() {
        AttestationStorageKey.allCases.forEach {
            secureStore.deleteItem(itemName: $0.rawValue)
        }
    }
    
    func delete() throws {
        AttestationStorageKey.allCases.forEach {
            secureStore.deleteItem(itemName: $0.rawValue)
        }
        try secureStore.delete()
    }
}
