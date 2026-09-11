@testable import OneLogin
import SecureStore

final class MockSecureStoreService: SecureStorable, SessionBoundData {
    /// This type can be used to track the number of calls made to a function
    /// - SeeAlso: ``mockClearSessionDataCounter`` on creating a mock with a counter to count the number of times ``SecureStorable/clearSessionData()`` is called
    /// - SeeAlso: ``mockDeleteCounter`` on creating a mock with a counter to count the number of times ``SecureStorable/delete()`` is called
    class Counter {
        var count = 0
        
        func increment() {
            self.count += 1
        }
        
        /// Returns true if a function has been called at least once
        func called() -> Bool {
            return count > 0
        }
    }
    
    final class SecureStoreData {
        fileprivate var storage: [AnyHashable: String]
        
        var isEmpty: Bool {
            self.storage.isEmpty
        }

        init(storage: [AnyHashable: String] = [:]) {
            self.storage = storage
        }
        
        subscript(key: AnyHashable) -> String? {
            get {
                storage[key]
            }
            set {
                storage[key] = newValue
            }
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
        let secureStoreData = SecureStoreData()
        let clearSessionDataCounter = Counter()
        
        let mockSecureStoreService = MockSecureStoreService(secureStoreData: secureStoreData)
        mockSecureStoreService.clearSessionDataAsFunction = clearSessionDataCount(secureStoreData: secureStoreData, counter: clearSessionDataCounter)

        return (mockSecureStoreService, clearSessionDataCounter)
    }

    /// Returns a Mock and a counter that can be used to assert how many times ``SecureStorable/readItem(itemName:)`` was called.
    static func mockReadItemCounter() -> (mockSecureStoreService: MockSecureStoreService, readItemCounter: Counter) {
        let secureStoreData = SecureStoreData()
        let readItemCounter = Counter()

        let mockSecureStoreService = MockSecureStoreService(secureStoreData: secureStoreData)
        mockSecureStoreService.readItemAsFunction = readItemCount(secureStoreData: secureStoreData, counter: readItemCounter)
        
        return (mockSecureStoreService, readItemCounter)
    }

    /// Returns a Mock and a counter than can be used to assert how many times the ``SecureStorable/delete`` was called
    static func mockDeleteCounter() -> (mockSecureStoreService: MockSecureStoreService, deleteCounter: Counter) {
        let deleteCounter = Counter()

        let mockSecureStoreService = MockSecureStoreService()
        mockSecureStoreService.deleteAsFunction = deleteCount(counter: deleteCounter)

        return (mockSecureStoreService, deleteCounter)
    }

    enum ReadItemResult {
        case error
        case success
    }
    
    static func readItemAsFunction(secureStoreData: SecureStoreData = SecureStoreData()) -> ReadItemAsFunction {
        func readItemAsFunction(itemName: String) throws(SecureStore.SecureStoreError) -> String {
            guard let item = secureStoreData[itemName] else {
                throw SecureStoreError(.unableToRetrieveFromUserDefaults)
            }
            
            return item
        }

        return readItemAsFunction
    }

    static func errorFromReadItem(_ error: SecureStoreError) -> ReadItemAsFunction {
        func readItemAsFunction(itemName: String) throws(SecureStore.SecureStoreError) -> String {
            throw error
        }

        return readItemAsFunction
    }
    
    static func errorFromSaveItem(_ error: SecureStore.SecureStoreError) -> SaveItemAsFunction {
        func saveItemAsFunction(item: String, itemName: String) throws {
            throw error
        }
        
        return saveItemAsFunction
    }

    static func readItemCount(secureStoreData: SecureStoreData, counter: Counter) -> ReadItemAsFunction {
        func readItemAsFunction(itemName: String) throws(SecureStore.SecureStoreError) -> String {
            defer {
                counter.increment()
            }
            
            guard let item = secureStoreData[itemName] else {
                throw SecureStoreError(.unableToRetrieveFromUserDefaults)
            }
            
            return item
        }

        return readItemAsFunction
    }

    static func deleteCount(counter: Counter) -> DeleteAsFunction {
        return {
            counter.increment()
        }
    }

    static func clearSessionDataCount(secureStoreData: SecureStoreData, counter: Counter) -> ClearSessionDataAsFunction {
        return {
            counter.increment()
            secureStoreData.storage = [:]
        }
    }

    typealias SaveItemAsFunction = (String, String) throws -> Void
    typealias ReadItemAsFunction = (String) throws(SecureStoreError) -> String
    typealias DeleteItemAsFunction = (String) -> Void
    typealias DeleteAsFunction = () throws -> Void
    typealias CheckItemExistsAsFunction = (String) -> Bool
    typealias ClearSessionDataAsFunction = () -> Void
    
    var saveItemAsFunction: SaveItemAsFunction
    var readItemAsFunction: ReadItemAsFunction
    var deleteItemAsFunction: DeleteItemAsFunction
    var deleteAsFunction: DeleteAsFunction
    var checkItemExistsAsFunction: CheckItemExistsAsFunction
    var clearSessionDataAsFunction: ClearSessionDataAsFunction
    
    var savedItems = [String: String]()

    init(saveItemAsFunction: @escaping SaveItemAsFunction = { _, _ in },
         readItemAsFunction: @escaping ReadItemAsFunction = { _ in "" },
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
    }
    
    func delete() throws {
        try self.deleteAsFunction()
    }
    
    func checkItemExists(itemName: String) -> Bool {
        return self.checkItemExistsAsFunction(itemName)
    }

    func clearSessionData() async throws {
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
