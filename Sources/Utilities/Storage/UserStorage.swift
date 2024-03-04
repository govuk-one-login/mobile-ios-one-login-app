import SecureStore

final class UserStorage: UserStorable {
    let secureStoreService: SecureStorable
    let defaultsStore: DefaultsStorable
    
    init(secureStoreService: SecureStorable, defaultsStore: DefaultsStorable) {
        self.secureStoreService = secureStoreService
        self.defaultsStore = defaultsStore
    }

    var returningAuthenticatedUser: Bool {
        (defaultsStore.value(forKey: "returningUser") != nil && defaultsStore.value(forKey: "accessTokenExpiry") != nil) ? true : false
    }
}
