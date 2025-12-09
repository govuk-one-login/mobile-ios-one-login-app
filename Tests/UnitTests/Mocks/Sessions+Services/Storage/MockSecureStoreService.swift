@testable import OneLogin
import SecureStore

final class MockSecureStoreService: SecureStorable, SessionBoundData {
    var savedItems = [String: String]()
    var didCallDeleteStore = false
    var didCallClearSessionData = false
    
    var errorFromSaveItem: Error?
    var errorFromReadItem: Error?
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
    
    func readItem(itemName: String) throws -> String {
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
