@testable import OneLogin
import SecureStore

final class MockSecureStoreService: SecureStorable {
    var savedItems = [String: String]()
    var didCallDeleteStore = false
    var didCallStart = false
    var didCallDeleteItem = false

    var errorFromSaveItem: Error?
    var isErrorFromReadItem = false

    func saveItem(item: String, itemName: String) throws {
        if let errorFromSaveItem {
            throw errorFromSaveItem
        } else {
            savedItems[itemName] = item
        }
    }
    
    func readItem(itemName: String) throws -> String? {
        if isErrorFromReadItem {
            try? deleteItem(itemName: itemName)
            didCallStart = true
        } else {
            savedItems[itemName]
        }
        return savedItems.isEmpty ? nil : savedItems[itemName]
    }
    
    func deleteItem(itemName: String) throws {
        didCallDeleteItem = true
        savedItems[itemName] = nil
    }
    
    func delete() throws {
        self.didCallDeleteStore = true
    }
    
    func checkItemExists(itemName: String) throws -> Bool { true }
}
