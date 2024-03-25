import Foundation
import SecureStore

protocol UserStorable {
    var secureStoreService: SecureStorable { get set }
    var defaultsStore: DefaultsStorable { get }
    
    func refreshStorage(accessControlLevel: SecureStorageConfiguration.AccessControlLevel)
}

extension UserStorable {
    var returningAuthenticatedUser: Bool {
        guard let accessTokenExpClaim = defaultsStore.value(forKey: .accessTokenExpiry) as? Date else {
            return false
        }
        return accessTokenExpClaim.timeIntervalSinceNow.sign == .plus
    }
    
    func storeTokenInfo(token: String, tokenExp: Date) throws {
        try secureStoreService.saveItem(item: token, itemName: .accessToken)
        if AppEnvironment.extendExpClaimEnabled {
            defaultsStore.set(tokenExp + 27 * 60, forKey: .accessTokenExpiry)
        } else {
            defaultsStore.set(tokenExp, forKey: .accessTokenExpiry)
        }
    }
    
    func clearTokenInfo() throws {
        try secureStoreService.deleteItem(itemName: .accessToken)
        defaultsStore.removeObject(forKey: .accessTokenExpiry)
    }
}
