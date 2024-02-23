import Foundation
import SecureStore

class UserStorage: UserStorable {
    var secureStoreService: SecureStorable
    var defaultsStore: DefaultsStorable
    
    init(secureStoreService: SecureStorable, defaultsStore: DefaultsStorable) {
        self.secureStoreService = secureStoreService
        self.defaultsStore = defaultsStore
    }
}
