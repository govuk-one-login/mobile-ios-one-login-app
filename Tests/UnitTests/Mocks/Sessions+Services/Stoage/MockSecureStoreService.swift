@testable import OneLogin
import SecureStore

final class MockSecureStoreService: SecureStorable {
    var savedItems: [ String: String ] = [:]
    
    func saveItem(item: String, itemName: String) throws {
        savedItems[itemName] = item
    }
    
    func readItem(itemName: String) throws -> String? { nil }
    
    func deleteItem(itemName: String) throws { }
    
    func delete() throws { }
    
    func checkItemExists(itemName: String) throws -> Bool { true }
}
