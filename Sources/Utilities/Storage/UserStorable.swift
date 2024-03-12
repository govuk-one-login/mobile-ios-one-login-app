import Foundation
import SecureStore

protocol UserStorable {
    var secureStoreService: SecureStorable { get set }
    var defaultsStore: DefaultsStorable { get }
    
    func refreshSecureStoreService()
}

extension UserStorable {
    var returningAuthenticatedUser: Bool {
        defaultsStore.value(forKey: .returningUser) != nil && defaultsStore.value(forKey: .accessTokenExpiry) != nil
    }
    
    var validAccessToken: Bool {
        guard let expClaim = defaultsStore.value(forKey: .accessTokenExpiry) as? Date else { return false }
        print(expClaim.timeIntervalSinceNow.sign == .plus)
        return expClaim.timeIntervalSinceNow.sign == .plus
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
