import SecureStore

final class SecureStoreManager: SessionBoundData {
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
