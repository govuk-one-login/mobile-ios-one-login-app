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
    
    static func encryptedStore() -> SecureStoreService & AttestationStorage {
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

extension SecureStoreService: @retroactive AttestationStorage {
    public var validAttestation: Bool {
        get throws {
            guard let expiresIn = Double(try readItem(itemName: AttestationStorageKey.attestationExpiry.rawValue)) else {
                throw AttestationStorageError.cantRetrieveAttestationJWT
            }
            return Date(timeIntervalSince1970: expiresIn) > .now
        }
    }
    
    public var attestationJWT: String {
        get throws {
            try readItem(itemName: AttestationStorageKey.clientAttestationJWT.rawValue)
        }
    }
    
    public func store(
        clientAttestation: String,
        attestationExpiry: String
    ) throws {
        try saveItem(
            item: clientAttestation,
            itemName: AttestationStorageKey.clientAttestationJWT.rawValue
        )
        try saveItem(
            item: attestationExpiry,
            itemName: AttestationStorageKey.attestationExpiry.rawValue
        )
    }
}
