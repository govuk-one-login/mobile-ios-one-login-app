import SecureStore

protocol UserStorable {
    var secureStoreService: SecureStorable { get }
    var defaultsStore: DefaultsStorable { get }
}

extension UserStorable {
    var returningAuthenticatedUser: Bool {
        defaultsStore.value(forKey: "returningUser") != nil && defaultsStore.value(forKey: "accessTokenExpiry") != nil
    }
}
