import Foundation
@testable import OneLogin
import SecureStore

class MockUserStore: UserStorable {
    var secureStoreService: SecureStorable
    let defaultsStore: DefaultsStorable

    init(secureStoreService: SecureStorable,
         defaultsStore: DefaultsStorable) {
        self.secureStoreService = secureStoreService
        self.defaultsStore = defaultsStore
    }
    
    func refreshSecureStoreService() { }
}
