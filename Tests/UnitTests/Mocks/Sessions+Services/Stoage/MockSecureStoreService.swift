@testable import OneLogin
import SecureStore

final class MockSecureStoreService: SecureStorable {
    var savedItems = [String: String]()
    var didCallDeleteStore = false
    
    var errorFromSaveItem: Error?
    var errorFromReadItem: Error?
    
    func saveItem(item: String, itemName: String) throws {
        if let errorFromSaveItem {
            throw errorFromSaveItem
        } else {
            savedItems[itemName] = item
        }
    }
    
    func readItem(itemName: String) throws -> String? {
        if let errorFromReadItem {
            throw errorFromReadItem
        } else {
            "testAccessToken"
        }
    }
    
    func deleteItem(itemName: String) throws {
        savedItems[itemName] = nil
    }
    
    func delete() throws {
        self.didCallDeleteStore = true
    }
    
    func checkItemExists(itemName: String) throws -> Bool { true }
}
