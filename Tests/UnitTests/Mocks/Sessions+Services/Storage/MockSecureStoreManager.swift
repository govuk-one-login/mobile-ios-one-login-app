import LocalAuthenticationWrapper
@testable import OneLogin
import SecureStore

class MockSecureStoreManager: SecureStoreManager {
    var accessControlEncryptedStore: SecureStorable
    var encryptedStore: SecureStorable
    var localAuthentication: LocalAuthManaging & LocalAuthenticationContextStrings
    
    var didCallRefreshStore = false
    
    init(accessControlEncryptedStore: SecureStorable,
         encryptedStore: SecureStorable,
         localAuthentication: LocalAuthManaging & LocalAuthenticationContextStrings) {
        self.accessControlEncryptedStore = accessControlEncryptedStore
        self.encryptedStore = encryptedStore
        self.localAuthentication = localAuthentication
    }
    
    func refreshStore() throws {
        didCallRefreshStore = true
    }
}
