import LocalAuthenticationWrapper
import SecureStore

protocol SecureStoreManager {
    var accessControlEncryptedStore: SecureStorable { get }
    var encryptedStore: SecureStorable { get }
    var localAuthentication: LocalAuthManaging & LocalAuthenticationContextStrings { get }
    func refreshStore() throws
}

final class OneLoginSecureStoreManager: SecureStoreManager {
    private(set) var accessControlEncryptedStore: SecureStorable
    private(set) var encryptedStore: SecureStorable
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
        encryptedStore: SecureStorable,
        localAuthentication: LocalAuthManaging & LocalAuthenticationContextStrings
    ) {
        self.accessControlEncryptedStore = accessControlEncryptedStore
        self.encryptedStore = encryptedStore
        self.localAuthentication = localAuthentication
    }
    
    func refreshStore() throws {
        try accessControlEncryptedStore.delete()
        try encryptedStore.delete()
        
        accessControlEncryptedStore = try .accessControlEncryptedStore(
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
