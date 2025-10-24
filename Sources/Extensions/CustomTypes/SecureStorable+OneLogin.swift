import AppIntegrity
import Foundation
import LocalAuthenticationWrapper
import SecureStore

extension SecureStorable where Self == SecureStoreService {
    static func accessControlEncryptedStore(
        localAuthManager: LocalAuthenticationContextStrings
    ) throws -> SecureStoreService {
        let accessControlConfiguration = SecureStorageConfiguration(
            id: OLString.oneLoginTokens,
            accessControlLevel: .anyBiometricsOrPasscode,
            localAuthStrings: try localAuthManager.oneLoginStrings
        )
        return SecureStoreService(
            configuration: accessControlConfiguration
        )
    }
    
    static func encryptedStore() -> SecureStoreService {
        let encryptedConfiguration = SecureStorageConfiguration(
            id: OLString.persistentSessionID,
            accessControlLevel: .open
        )
        return SecureStoreService(configuration: encryptedConfiguration)
    }
}

extension SecureStoreService: SessionBoundData { }

enum AttestationStorageKey: String {
    case clientAttestationJWT
    case attestationExpiry
}

enum AttestationStorageError: Error {
    case cantRetrieveAttestationJWT
}

extension SecureStorable {
    func saveDate(id: String, _ date: Date) throws {
        try saveItem(
            item: date.timeIntervalSince1970.description,
            itemName: id
        )
    }
    
    func readDate(id: String) throws -> Date {
        let dateString = try readItem(itemName: AttestationStorageKey.attestationExpiry.rawValue)
        guard let dateDouble = Double(dateString) else {
            fatalError("Failed to decode date from string: \(dateString)")
        }
        return Date(timeIntervalSince1970: dateDouble)
    }
}

final class SecureAttestationStore: AttestationStorage {
    private let secureStore: SecureStorable
    
    var attestationExpired: Bool {
        get throws {
            try secureStore.readDate(id: AttestationStorageKey.attestationExpiry.rawValue) <= .now
        }
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
                id: "secure-attestation-store",
                accessControlLevel: .open
            )
        )
    ) {
        self.secureStore = secureStore
    }
}
