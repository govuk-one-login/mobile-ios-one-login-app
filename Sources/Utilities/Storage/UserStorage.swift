import SecureStore

final class UserStorage: UserStorable {
    var secureStoreService: SecureStorable?
    let defaultsStore: DefaultsStorable
    
    init(defaultsStore: DefaultsStorable) {
        self.defaultsStore = defaultsStore
    }
}
