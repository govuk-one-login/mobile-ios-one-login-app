import LocalAuthentication
import SecureStore

final class UserStorage: UserStorable {
    var secureStoreService: SecureStorable
    var openSecureStoreService: SecureStorable
    let defaultsStore: DefaultsStorable
    
    init(secureStoreService: SecureStorable,
         openSecureStoreService: SecureStorable,
         defaultsStore: DefaultsStorable) {
        self.secureStoreService = secureStoreService
        self.openSecureStoreService = openSecureStoreService
        self.defaultsStore = defaultsStore
    }
    
    func refreshStorage(accessControlLevel: SecureStorageConfiguration.AccessControlLevel) {
        clearTokenInfo()
        do {
            try secureStoreService.delete()
        } catch {
            print("Deleting Secure Store error: \(error)")
        }
        secureStoreService = SecureStoreService(configuration: .init(id: .oneLoginTokens,
                                                                     accessControlLevel: accessControlLevel,
                                                                     localAuthStrings: LAContext().contextStrings))
    }
}
