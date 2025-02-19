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
    
    init(localAuthentication: LocalAuthenticationManager & LocalAuthenticationContextStringCheck) {
        self.accessControlEncryptedStore = SecureStoreService.accessControlEncryptedStore(
            localAuthManager: localAuthentication
        )
        self.encryptedStore = SecureStoreService.encryptedStore()
        self.localAuthentication = localAuthentication
    }
    
    func delete() throws {
        try accessControlEncryptedStore.delete()
        try encryptedStore.delete()
        
        accessControlEncryptedStore = SecureStoreService.accessControlEncryptedStore(
            localAuthManager: localAuthentication
        )
        encryptedStore = SecureStoreService.encryptedStore()
    }
}
