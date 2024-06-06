import LocalAuthentication
import SecureStore

final class UserStorage: UserStorable {
    var secureStoreService: SecureStorable
    let defaultsStore: DefaultsStorable
    
    init(secureStoreService: SecureStorable,
         defaultsStore: DefaultsStorable) {
        self.secureStoreService = secureStoreService
        self.defaultsStore = defaultsStore
    }
    
    func refreshStorage(accessControlLevel: SecureStorageConfiguration.AccessControlLevel) {
        do {
            clearTokenInfo()
            try secureStoreService.delete()
        } catch {
            print("Deleting Secure Store error: \(error)")
        }
        secureStoreService = SecureStoreService(configuration: .init(id: .oneLoginTokens,
                                                                     accessControlLevel: accessControlLevel,
                                                                     localAuthStrings: LAContext().contextStrings))
    }
}
