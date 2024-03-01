import SecureStore

protocol UserStorable {
    var secureStoreService: SecureStorable { get }
    var defaultsStore: DefaultsStorable { get }
}
