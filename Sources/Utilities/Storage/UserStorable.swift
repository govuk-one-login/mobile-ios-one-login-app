import Foundation
import SecureStore

protocol UserStorable {
    var secureStoreService: SecureStorable { get }
    var defaultsStore: DefaultsStorable { get }
}

extension UserStorable {
    var returningAuthenticatedUser: Bool {
        defaultsStore.value(forKey: .returningUser) != nil && defaultsStore.value(forKey: .accessTokenExpiry) != nil
    }
    
    var validAccessToken: Bool {
        guard let expClaim = defaultsStore.value(forKey: .accessTokenExpiry) as? Date else { return false }
        return expClaim.timeIntervalSinceNow.sign == .plus ? true : false
    }
    
    func clearTokenInfo() throws {
        defaultsStore.removeObject(forKey: .accessTokenExpiry)
        try secureStoreService.deleteItem(itemName: .accessToken)
    }
}
