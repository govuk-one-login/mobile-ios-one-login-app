@testable import OneLogin
import SecureStore

final class MockSecureStore: SecureStorable {
    func saveItem(item: String, itemName: String) throws {
        
    }
    
    func readItem(itemName: String) throws -> String? {
        nil
    }
    
    func deleteItem(itemName: String) throws {
        
    }
    
    func delete() throws {
        
    }
    
    func checkItemExists(itemName: String) throws -> Bool {
        true
    }
}
