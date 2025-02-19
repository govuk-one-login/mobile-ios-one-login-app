import SecureStore

protocol SecureStoreManager {
    var accessControlEncryptedStore: SecureStorable { get }
    var encryptedStore: SecureStorable { get }
    var localAuthentication: LocalAuthenticationManager & LocalAuthenticationContextStringCheck { get }
}

final class OneLoginSecureStoreManager: SecureStoreManager, SessionBoundData {
    var accessControlEncryptedStore: SecureStorable
    var encryptedStore: SecureStorable
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
    
    func delete() throws {
        try accessControlEncryptedStore.delete()
        try encryptedStore.delete()
        
        accessControlEncryptedStore = .accessControlEncryptedStore(
            localAuthManager: localAuthentication
        )
        encryptedStore = .encryptedStore()
    }
}
