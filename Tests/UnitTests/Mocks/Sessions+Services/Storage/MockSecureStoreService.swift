@testable import OneLogin
import SecureStore

final class MockSecureStoreService: SecureStorable, SessionBoundData {
    
    static func makeWithStoredTokens(idToken: String = MockJWTs.genericToken,
                                     refreshToken: String = MockJWTs.genericToken,
                                     accessToken: String = MockJWTs.genericToken
    ) throws -> MockSecureStoreService {
        let mockAccessControlEncryptedStore = MockSecureStoreService()
        let data = StoredTokens.encodeKeys(
            idToken: idToken,
            refreshToken: refreshToken,
            accessToken: accessToken
        )
        try mockAccessControlEncryptedStore.saveItem(
            item: data,
            itemName: OLString.storedTokens
        )
        
        return mockAccessControlEncryptedStore
    }
    
    var savedItems = [String: String]()
    var didCallDeleteStore = false
    var didCallClearSessionData = false
    
    var errorFromSaveItem: Error?
    var errorFromReadItem: SecureStoreError?
    var errorFromClearSessionData: Error?
    var returnFromCheckItemExists = true
    
    func checkItemExists(itemName: String) -> Bool {
        if savedItems[itemName] != nil {
            return true
        }
        return false
    }
    
    func saveItem(item: String, itemName: String) throws {
        if let errorFromSaveItem {
            throw errorFromSaveItem
        } else {
            savedItems[itemName] = item
        }
    }
    
    func readItem(itemName: String) throws(SecureStoreError) -> String {
        if let errorFromReadItem {
            throw errorFromReadItem
        } else {
            guard let savedItem = savedItems[itemName] else {
                throw SecureStoreError(.unableToRetrieveFromUserDefaults)
            }
            return savedItem
        }
    }
    
    func deleteItem(itemName: String) {
        savedItems[itemName] = nil
    }
    
    func delete() throws {
        didCallDeleteStore = true
        savedItems = [:]
    }
    
    func clearSessionData() throws {
        if let errorFromClearSessionData {
            throw errorFromClearSessionData
        }
        didCallClearSessionData = true
        savedItems = [:]
    }
}
