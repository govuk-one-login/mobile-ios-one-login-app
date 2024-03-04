import Foundation
import SecureStore

class MockUserStore: UserStorable {
    let secureStoreService: SecureStorable
    let defaultsStore: DefaultsStorable
    var returningAuthenticatedUser: Bool = true

    init(secureStoreService: SecureStorable, defaultsStore: DefaultsStorable) {
        self.secureStoreService = secureStoreService
        self.defaultsStore = defaultsStore
    }
}
