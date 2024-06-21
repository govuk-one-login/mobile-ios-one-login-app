import Foundation
@testable import OneLoginNOW
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
