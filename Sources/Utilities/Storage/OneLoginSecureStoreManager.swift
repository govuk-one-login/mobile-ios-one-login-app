import AppIntegrity
import LocalAuthenticationWrapper
import SecureStore

protocol SecureStoreManager {
    var accessControlEncryptedStore: SecureStorable { get }
    var encryptedStore: SecureStorable & AttestationStorage { get }
    var localAuthentication: LocalAuthManaging & LocalAuthenticationContextStrings { get }
}

final class OneLoginSecureStoreManager: SecureStoreManager {
    let accessControlEncryptedStore: SecureStorable
    let encryptedStore: SecureStorable & AttestationStorage
    let localAuthentication: LocalAuthManaging & LocalAuthenticationContextStrings
    
    convenience init(
        localAuthentication: LocalAuthManaging & LocalAuthenticationContextStrings = LocalAuthenticationWrapper(
            localAuthStrings: .oneLogin
        )
    ) throws {
        self.init(
            accessControlEncryptedStore: try .accessControlEncryptedStore(
                localAuthManager: localAuthentication
            ),
            encryptedStore: .encryptedStore(),
            localAuthentication: localAuthentication
        )
    }
    
    init(
        accessControlEncryptedStore: SecureStorable,
        encryptedStore: SecureStorable & AttestationStorage,
        localAuthentication: LocalAuthManaging & LocalAuthenticationContextStrings
    ) {
        self.accessControlEncryptedStore = accessControlEncryptedStore
        self.encryptedStore = encryptedStore
        self.localAuthentication = localAuthentication
    }
}
