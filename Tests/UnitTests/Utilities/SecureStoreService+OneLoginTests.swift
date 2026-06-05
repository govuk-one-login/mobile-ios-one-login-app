@testable import OneLogin
import SecureStore
import Testing

struct SecureStoreServiceTests: ~Copyable {
    var sut: SecureStoreServiceV2!
    
    init() throws {
        let config = SecureStorageConfiguration(
            id: "testConfig",
            accessControlLevel: .open
        )
        sut = SecureStoreServiceV2(configuration: config)
        
        try sut.saveItem(
            item: "testRefreshTokenExpiry",
            itemName: OLString.refreshTokenExpiry
        )
        try sut.saveItem(
            item: "testPersistentSessionID",
            itemName: OLString.persistentSessionID
        )
        try sut.saveItem(
            item: "testStoredTokens",
            itemName: OLString.storedTokens
        )
    }
    
    deinit {
        try? sut.delete()
    }

    @Test("Clear session data deletes the refresh token, persistentSessionID and tokens")
    func delete() throws {
        #expect(try sut.readItem(itemName: OLString.refreshTokenExpiry) == "testRefreshTokenExpiry")
        #expect(try sut.readItem(itemName: OLString.persistentSessionID) == "testPersistentSessionID")
        #expect(try sut.readItem(itemName: OLString.storedTokens) == "testStoredTokens")
        sut.clearSessionData()
        #expect(throws: SecureStoreErrorV2(.unableToRetrieveFromUserDefaults)) {
            try sut.readItem(itemName: OLString.refreshTokenExpiry)
        }
        #expect(throws: SecureStoreErrorV2(.unableToRetrieveFromUserDefaults)) {
            try sut.readItem(itemName: OLString.persistentSessionID)
        }
        #expect(throws: SecureStoreErrorV2(.unableToRetrieveFromUserDefaults)) {
            try sut.readItem(itemName: OLString.storedTokens)
        }
    }
    
    @Test("Secure Enclave tag and stored private-key tag resolve to the same key pair")
    func secureEnclaveKeyAndStoredPrivateKeyAreSameKeyPair() throws {
        let id = UUID().uuidString
        let sut = KeyManagerService(configuration: .init(
            id: id,
            accessControlLevel: .open
        ))

        defer {
            try? sut.deleteKeys()
            deleteKey(tag: id)
            deleteKey(tag: "\(id)PrivateKey")
        }

        let secureEnclaveTaggedKey = try privateKey(tag: id)
        let storedPrivateKey = try privateKey(tag: "\(id)PrivateKey")

        #expect(try publicKeyData(from: secureEnclaveTaggedKey) == publicKeyData(from: storedPrivateKey))
    }

    private func privateKey(tag: String) throws -> SecKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: Data(tag.utf8),
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]

        var ref: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &ref)
        #expect(status == errSecSuccess)
        return ref as! SecKey
    }

    private func publicKeyData(from privateKey: SecKey) throws -> Data {
        let publicKey = try #require(SecKeyCopyPublicKey(privateKey))

        var error: Unmanaged<CFError>?
        let data = SecKeyCopyExternalRepresentation(publicKey, &error)
        return try #require(data as Data?)
    }

    private func deleteKey(tag: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: Data(tag.utf8)
        ]
        SecItemDelete(query as CFDictionary)
    }
}
