import Foundation
@testable import OneLogin
import SecureStore

class MockUserStore: UserStorable {
    var secureStoreService: SecureStorable
    let defaultsStore: DefaultsStorable
    var shouldPromptForAnalytics: Bool?

    init(secureStoreService: SecureStorable,
         defaultsStore: DefaultsStorable) {
        self.secureStoreService = secureStoreService
        self.defaultsStore = defaultsStore
    }
    
    func refreshStorage(accessControlLevel: SecureStorageConfiguration.AccessControlLevel) { }
}
