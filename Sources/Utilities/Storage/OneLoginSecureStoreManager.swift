import SecureStore

protocol SecureStoreManager {
    var accessControlEncryptedStore: SecureStorable { get }
    var encryptedStore: SecureStorable { get }
    var localAuthentication: LocalAuthenticationManager & LocalAuthenticationContextStringCheck { get }
    func refreshStore() throws
}

final class OneLoginSecureStoreManager: SecureStoreManager {
    private(set) var accessControlEncryptedStore: SecureStorable
    private(set) var encryptedStore: SecureStorable
    let localAuthentication: LocalAuthenticationManager & LocalAuthenticationContextStringCheck
    
    convenience init(localAuthentication: LocalAuthenticationManager & LocalAuthenticationContextStringCheck) {
        self.init(
            accessControlEncryptedStore: .accessControlEncryptedStore(
                localAuthManager: localAuthentication
            ),
            encryptedStore: .encryptedStore(),
            localAuthentication: localAuthentication
        )
    }
    
    init(accessControlEncryptedStore: SecureStorable,
         encryptedStore: SecureStorable,
         localAuthentication: LocalAuthenticationManager & LocalAuthenticationContextStringCheck) {
        self.accessControlEncryptedStore = accessControlEncryptedStore
        self.encryptedStore = encryptedStore
        self.localAuthentication = localAuthentication
    }
    
    func refreshStore() throws {
        try accessControlEncryptedStore.delete()
        try encryptedStore.delete()
        
        accessControlEncryptedStore = .accessControlEncryptedStore(
            localAuthManager: localAuthentication
        )
        encryptedStore = .encryptedStore()
    }
}

extension OneLoginSecureStoreManager: SessionBoundData {
    func delete() throws {
        try refreshStore()
    }
}
