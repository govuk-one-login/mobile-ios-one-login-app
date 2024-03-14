import SecureStore

protocol UserStorable {
    var secureStoreService: SecureStorable { get set }
    var defaultsStore: DefaultsStorable { get }

    func refreshSecureStoreService()
}

extension UserStorable {
    var returningAuthenticatedUser: Bool {
        defaultsStore.value(forKey: "returningUser") != nil && defaultsStore.value(forKey: "accessTokenExpiry") != nil
    }
}
