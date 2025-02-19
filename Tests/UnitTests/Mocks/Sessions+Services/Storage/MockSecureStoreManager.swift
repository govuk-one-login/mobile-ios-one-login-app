@testable import OneLogin
import SecureStore

class MockSecureStoreManager: SecureStoreManager {
    var accessControlEncryptedStore: SecureStorable
    var encryptedStore: SecureStorable
    var localAuthentication: LocalAuthenticationContextStringCheck & LocalAuthenticationManager
    
    init(accessControlEncryptedStore: SecureStorable,
         encryptedStore: SecureStorable,
         localAuthentication: LocalAuthenticationContextStringCheck & LocalAuthenticationManager) {
        self.accessControlEncryptedStore = accessControlEncryptedStore
        self.encryptedStore = encryptedStore
        self.localAuthentication = localAuthentication
    }
}
