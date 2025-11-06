@testable import OneLogin

final class MockSecureStoreManager: SecureStoreManaging, SessionBoundData {
    var savedItems = [String: String]()
    
    func clearSessionData() async throws {
        
    }
    
    func checkItemExists(_ itemName: String) -> Bool {
        true
    }
    
    func saveItem(_ item: String, itemName: String) throws {
        
    }
    
    func readItem(_ itemName: String) throws -> String {
        ""
    }
    
    func deleteItem(_ itemName: String) {
        
    }
}
