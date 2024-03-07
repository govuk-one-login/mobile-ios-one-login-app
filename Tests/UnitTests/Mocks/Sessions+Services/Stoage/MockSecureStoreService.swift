@testable import OneLogin
import SecureStore

final class MockSecureStoreService: SecureStorable {
    var savedItems: [ String: String ] = [:]
    
    var errorFromReadItem: Error?
    
    func saveItem(item: String, itemName: String) throws {
        savedItems[itemName] = item
    }
    
    func readItem(itemName: String) throws -> String? {
        if let errorFromReadItem {
            throw errorFromReadItem
        } else {
            "testAccessToken"
        }
    }
    
    func deleteItem(itemName: String) throws { }
    
    func delete() throws { }
    
    func checkItemExists(itemName: String) throws -> Bool { true }
}
