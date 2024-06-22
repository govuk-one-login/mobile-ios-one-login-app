import Authentication
import Foundation
import SecureStore

protocol UserStorable {
    var secureStoreService: SecureStorable { get set }
    var defaultsStore: DefaultsStorable { get }
    
    func refreshStorage(accessControlLevel: SecureStorageConfiguration.AccessControlLevel)
}

extension UserStorable {
    var previouslyAuthenticatedUser: Date? {
        defaultsStore.value(forKey: .accessTokenExpiry) as? Date
    }
    
    var validAuthenticatedUser: Bool {
        guard let previouslyAuthenticatedUser else {
            return false
        }
        return previouslyAuthenticatedUser.timeIntervalSinceNow.sign == .plus
    }
    
    func storeTokenInfo(tokenResponse: TokenResponse) throws {
        let accessToken = tokenResponse.accessToken
        let tokenExp = tokenResponse.expiryDate
        try secureStoreService.saveItem(item: accessToken, itemName: .accessToken)
        if AppEnvironment.extendExpClaimEnabled {
            defaultsStore.set(tokenExp + 27 * 60, forKey: .accessTokenExpiry)
        } else {
            defaultsStore.set(Date(), forKey: .accessTokenExpiry)
        }
        // TODO: DCMAW-8570 This should be considiered non-optional once tokenID work is completed on BE
        if let idToken = tokenResponse.idToken {
            try secureStoreService.saveItem(item: idToken, itemName: .idToken)
        }
    }
    
    func clearTokenInfo() {
        secureStoreService.deleteItem(itemName: .accessToken)
        secureStoreService.deleteItem(itemName: .idToken)
        defaultsStore.removeObject(forKey: .accessTokenExpiry)
    }
}
