import LocalAuthentication
import SecureStore

final class UserStorage: UserStorable {
    var authenticatedStore: SecureStorable
    var openStore: SecureStorable
    let defaultsStore: DefaultsStorable
    
    init(authenticatedStore: SecureStorable,
         openStore: SecureStorable,
         defaultsStore: DefaultsStorable) {
        self.authenticatedStore = authenticatedStore
        self.openStore = openStore
        self.defaultsStore = defaultsStore
    }
    
    func refreshStorage(accessControlLevel: SecureStorageConfiguration.AccessControlLevel?) {
        do {
            try authenticatedStore.delete()
        } catch {
            print("Deleting Secure Store error: \(error)")
        }
        let laContext = LAContext()
        if let accessControlLevel {
            authenticatedStore = SecureStoreService(configuration: .init(id: .oneLoginTokens,
                                                                         accessControlLevel: accessControlLevel,
                                                                         localAuthStrings: laContext.contextStrings))
        } else {
            authenticatedStore = SecureStoreService(configuration: .init(id: .oneLoginTokens,
                                                                         accessControlLevel: laContext.isPasscodeOnly ? .anyBiometricsOrPasscode : .currentBiometricsOrPasscode,
                                                                         localAuthStrings: laContext.contextStrings))
        }
    }
}
