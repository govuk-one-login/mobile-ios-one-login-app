import Foundation
@testable import OneLogin
import SecureStore

class MockUserStore: UserStorable {
    var secureStoreService: SecureStorable
    var openSecureStoreService: SecureStorable
    let defaultsStore: DefaultsStorable
    var shouldPromptForAnalytics: Bool?

    init(secureStoreService: SecureStorable,
         openSecureStoreService: SecureStorable,
         defaultsStore: DefaultsStorable) {
        self.secureStoreService = secureStoreService
        self.openSecureStoreService = openSecureStoreService
        self.defaultsStore = defaultsStore
    }
    
    func refreshStorage(accessControlLevel: SecureStorageConfiguration.AccessControlLevel) { }
}
