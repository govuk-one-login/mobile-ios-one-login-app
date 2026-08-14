@testable import OneLogin
import SecureStore

final class MockSecureStoreService: SecureStorable, SessionBoundData {

    /// This type can be used to track the number of calls made to a function
    /// - SeeAlso: ``mockClearSessionDataCounter`` on creating a mock with a counter to count the number of times ``SecureStorable/clearSessionData()`` is called
    /// - SeeAlso: ``mockDeleteCounter`` on creating a mock with a counter to count the number of times ``SecureStorable/delete()`` is called
    class Counter {
        var count = 0
        
        func increment() {
            self.count = +1
        }
        
        /// Returns true if a function has been called at least once
        func called() -> Bool {
            return count > 0
        }
    }
    
    /// Returns a new mock that can be used as the `AccessControlEncryptedStore` and has stored tokens under the ``OLString/storedTokens``.
    ///
    /// - Parameters:
    ///     - idToken: the id token; ``MockJWTs/genericToken`` by default
    ///     - refreshToken: the id token; ``MockJWTs/genericToken`` by default
    ///     - accessToken: the id token; ``MockJWTs/genericToken`` by default
    /// - SeeAlso: ``PersistentSessionManager`` which uses an `AccessControlEncryptedStore`
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
    
    /// Returns a Mock and a counter than can be used to assert the ``SecureStorable/clearSessionData`` has been called
    static func mockClearSessionDataCounter() -> (mockSecureStoreService: MockSecureStoreService, clearSessionDataCounter: Counter) {
        let clearSessionDataCounter = Counter()
        
        return (MockSecureStoreService(
            clearSessionDataAsFunction: clearSessionDataCount(counter: clearSessionDataCounter)), clearSessionDataCounter)
    }

    /// Returns a Mock and a counter than can be used to assert the ``SecureStorable/delete`` has been called
    static func mockDeleteCounter() -> (mockSecureStoreService: MockSecureStoreService, deleteCounter: Counter) {
        let deleteCounter = Counter()
        
        return (MockSecureStoreService(deleteAsFunction: deleteCount(counter: deleteCounter)), deleteCounter)
    }

    enum ReadItemResult {
        case error
        case success
    }
    
    static func errorFromReadItem(_ error: SecureStore.SecureStoreError) -> ReadItemAsFunction {
        func readItemAsFunction(itemName: String) throws(SecureStore.SecureStoreError) -> String {
            throw error
        }

        return readItemAsFunction
    }
    
    static func errorFromSaveItem(_ error: SecureStore.SecureStoreError) -> SaveItemAsFunction {
        // swiftlint:disable redundant_void_return
        func saveItemAsFunction(item: String, itemName: String) throws -> Void {
            throw error
        }
        // swiftlint:enable redundant_void_return
        
        return saveItemAsFunction
    }

    static func deleteCount(counter: Counter) -> DeleteAsFunction {
        return {
            counter.increment()
        }
    }

    static func clearSessionDataCount(counter: Counter) -> ClearSessionDataAsFunction {
        return {
            counter.increment()
        }
    }

    typealias SaveItemAsFunction = (String, String) throws -> Void
    typealias ReadItemAsFunction = (String) throws(SecureStore.SecureStoreError) -> String
    typealias DeleteItemAsFunction = (String) -> Void
    typealias DeleteAsFunction = () throws -> Void
    typealias ClearSessionDataAsFunction = () -> Void
    
    var saveItemAsFunction: SaveItemAsFunction
    var readItemAsFunction: ReadItemAsFunction
    var deleteItemAsFunction: DeleteItemAsFunction
    var deleteAsFunction: DeleteAsFunction
    var clearSessionDataAsFunction: ClearSessionDataAsFunction
    
    var savedItems = [String: String]()

    init(saveItemAsFunction: @escaping SaveItemAsFunction = { _, _ in },
         readItemAsFunction: @escaping ReadItemAsFunction =  { _ in "" },
         deleteItemAsFunction: @escaping DeleteItemAsFunction = { _ in },
         deleteAsFunction: @escaping DeleteAsFunction = {},
         clearSessionDataAsFunction: @escaping ClearSessionDataAsFunction = {}) {
        self.saveItemAsFunction = saveItemAsFunction
        self.readItemAsFunction = readItemAsFunction
        self.deleteItemAsFunction = deleteItemAsFunction
        self.deleteAsFunction = deleteAsFunction
        self.clearSessionDataAsFunction = clearSessionDataAsFunction
    }
    
    func saveItem(item: String, itemName: String) throws {
        self.savedItems[itemName] = item
        try self.saveItemAsFunction(item, itemName)
    }
    
    func readItem(itemName: String) throws(SecureStore.SecureStoreError) -> String {
        _ = try self.readItemAsFunction(itemName)
        
        guard let savedItem = self.savedItems[itemName] else {
            throw SecureStoreError(.unableToRetrieveFromUserDefaults)
        }
        return savedItem

    }
    
    func deleteItem(itemName: String) {
        self.deleteItemAsFunction(itemName)
        self.savedItems[itemName] = nil
    }
    
    func delete() throws {
        self.savedItems = [:]
        try self.deleteAsFunction()
    }
    
    func checkItemExists(itemName: String) -> Bool {
        return self.savedItems[itemName] != nil
    }

    
    func clearSessionData() async throws {
        self.savedItems = [:]
        self.clearSessionDataAsFunction()
    }
    
    // MARK: Helpers    
    var _errorFromSaveItem: SecureStoreError?
    var errorFromSaveItem: SecureStoreError? {
        get {
            _errorFromSaveItem
        }
        set {
            switch newValue {
            case .none:
                _errorFromSaveItem = nil
                self.saveItemAsFunction = { _, _ in }
            case .some(let error):
                self.saveItemAsFunction = Self.errorFromSaveItem(error)
            }
        }
    }
}
