import Foundation
@testable import OneLogin
import SecureStore

class MockUserStore: UserStorable {
    var authenticatedStore: SecureStorable
    var openStore: SecureStorable
    let defaultsStore: DefaultsStorable
    var shouldPromptForAnalytics: Bool?

    init(authenticatedStore: SecureStorable,
         openStore: SecureStorable,
         defaultsStore: DefaultsStorable) {
        self.authenticatedStore = authenticatedStore
        self.openStore = openStore
        self.defaultsStore = defaultsStore
    }
    
    func refreshStorage(accessControlLevel: SecureStorageConfiguration.AccessControlLevel) { }
}
