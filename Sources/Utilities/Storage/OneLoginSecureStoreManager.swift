import LocalAuthenticationWrapper
import SecureStore

protocol SecureStoreManager {
    var accessControlEncryptedStore: SecureStorable { get }
    var encryptedStore: SecureStorable { get }
}

final class OneLoginSecureStoreManager: SecureStoreManager {
    let accessControlEncryptedStore: SecureStorable
    let encryptedStore: SecureStorable
    
    convenience init(
        localAuthentication: LocalAuthManaging & LocalAuthenticationContextStrings = LocalAuthenticationWrapper(
            localAuthStrings: .oneLogin
        )
    ) throws {
        self.init(
            accessControlEncryptedStore: try .accessControlEncryptedStore(
                localAuthManager: localAuthentication
            ),
            encryptedStore: .encryptedStore()
        )
    }
    
    init(
        accessControlEncryptedStore: SecureStorable,
        encryptedStore: SecureStorable,
    ) {
        self.accessControlEncryptedStore = accessControlEncryptedStore
        self.encryptedStore = encryptedStore
    }
}
