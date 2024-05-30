import Authentication
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
    
    var shouldPromptForAnalytics: Bool {
        get {
            guard let shouldPrompt = defaultsStore.value(forKey: .shouldPromptForAnalytics) as? Bool else {
                return true
            }
            return shouldPrompt
        } set {
            defaultsStore.set(newValue, forKey: .shouldPromptForAnalytics)
        }
    }
    
    func storeTokenInfo(tokenResponse: TokenResponse) throws {
        let accessToken = tokenResponse.accessToken
        let tokenExp = tokenResponse.expiryDate
        try secureStoreService.saveItem(item: accessToken, itemName: .accessToken)
        if AppEnvironment.extendExpClaimEnabled {
            defaultsStore.set(tokenExp + 27 * 60, forKey: .accessTokenExpiry)
        } else {
            defaultsStore.set(tokenExp, forKey: .accessTokenExpiry)
        }
        // TODO: DCMAW-8570 This should be considiered non-optional once tokenID work is completed on BE
        if let idToken = tokenResponse.idToken {
            try secureStoreService.saveItem(item: idToken, itemName: .idToken)
        }
    }
    
    func clearTokenInfo() throws {
        try secureStoreService.deleteItem(itemName: .accessToken)
        try secureStoreService.deleteItem(itemName: .idToken)
        defaultsStore.removeObject(forKey: .accessTokenExpiry)
    }
}
