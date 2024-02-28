import Foundation
import SecureStore

class UserStorage: UserStorable {
    let secureStoreService: SecureStorable
    let defaultsStore: DefaultsStorable
    
    init(secureStoreService: SecureStorable, defaultsStore: DefaultsStorable) {
        self.secureStoreService = secureStoreService
        self.defaultsStore = defaultsStore
    }
}