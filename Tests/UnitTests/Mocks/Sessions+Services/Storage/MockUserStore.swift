import Foundation
#if NOW
@testable import OneLoginNOW
#else
@testable import OneLogin
#endif

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
