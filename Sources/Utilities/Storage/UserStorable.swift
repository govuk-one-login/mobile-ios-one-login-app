import Authentication
import Foundation
import SecureStore

enum Storage {
    case authenticated
    case open
}

protocol UserStorable {
    var authenticatedStore: SecureStorable { get set }
    var openStore: SecureStorable { get set }
    var defaultsStore: DefaultsStorable { get }
    
    func refreshStorage(accessControlLevel: SecureStorageConfiguration.AccessControlLevel?)
}

extension UserStorable {
    var previouslyAuthenticatedUser: Date? {
        defaultsStore.value(forKey: .accessTokenExpiry) as? Date
    }
    
    var validAuthenticatedUser: Bool {
        previouslyAuthenticatedUser?.timeIntervalSinceNow.sign == .plus
    }
    
    func storeTokenInfo() {
        guard let tokenResponse = TokenHolder.shared.tokenResponse else { return }
        if let _ = try? saveItem(tokenResponse.accessToken, itemName: .accessToken, storage: .authenticated),
           let _ = try? saveItem(tokenResponse.idToken, itemName: .idToken, storage: .authenticated),
           let _ = try? saveItem(TokenHolder.shared.idTokenPayload?.persistentId, itemName: .persistentSessionID, storage: .open) {
            defaultsStore.set(tokenResponse.expiryDate, forKey: .accessTokenExpiry)
            defaultsStore.set(true, forKey: .returningUser)
        }
    }
    
    func clearTokenInfo() {
        authenticatedStore.deleteItem(itemName: .accessToken)
        authenticatedStore.deleteItem(itemName: .idToken)
        defaultsStore.removeObject(forKey: .accessTokenExpiry)
    }
    
    func missingPersistentId() -> Bool {
        if !openStore.checkItemExists(itemName: .persistentSessionID) {
            if defaultsStore.value(forKey: .returningUser) != nil {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func removePersistentSessionId() {
        openStore.deleteItem(itemName: .persistentSessionID)
    }
    
    func saveItem(_ item: String?, itemName: String, storage: Storage) throws {
        guard let item else { return }
        switch storage {
        case .authenticated:
            try authenticatedStore.saveItem(item: item, itemName: itemName)
        case .open:
            try openStore.saveItem(item: item, itemName: itemName)
        }
    }
    
    func readItem(itemName: String, storage: Storage) throws -> String {
        switch storage {
        case .authenticated:
            return try authenticatedStore.readItem(itemName: itemName)
        case .open:
            return try openStore.readItem(itemName: itemName)
        }
    }
    
    func constructLoginSessionConfiguration() -> LoginSessionConfiguration {
        let persistentSessionID = try? readItem(itemName: .persistentSessionID, storage: .open)
        if persistentSessionID == nil {
            debugPrint("No persistentSessionID found in SecureStore")
        }
        return LoginSessionConfiguration.oneLogin(persistentSessionId: persistentSessionID)
    }
}
