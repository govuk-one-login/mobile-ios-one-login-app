@testable import OneLogin
import SecureStore

final class MockSecureStoreService: SecureStorable {
    var savedItems = [String: String]()
    var didCallDeleteStore = false
    
    var errorFromSaveItem: Error?
    var errorFromReadItem: Error?
    var errorFromDeleteItem: Error?
    var returnFromCheckItemExists = true
    
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
                throw SecureStoreError.unableToRetrieveFromUserDefaults
            }
            return savedItem
        }
    }
    
    func deleteItem(itemName: String) {
        savedItems[itemName] = nil
    }
    
    func delete() throws {
        didCallDeleteStore = true
        if let errorFromDeleteItem {
            throw errorFromDeleteItem
        }
    }
    
    func checkItemExists(itemName: String) -> Bool {
        if savedItems[itemName] != nil {
            return true
        }
        return false
    }
}
