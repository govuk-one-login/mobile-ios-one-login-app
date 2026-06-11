import Foundation
@testable import OneLogin

class MockDefaultsStore: DefaultsStoring, SessionBoundData {
    var savedData = [String: Any]()
    
    func set(_ value: Any?, forKey defaultName: String) {
        savedData[defaultName] = value
    }
    
    func value(forKey key: String) -> Any? {
        savedData[key]
    }
    
    func bool(forKey: String) -> Bool {
        savedData[forKey] as? Bool ?? false
    }
    
    func removeObject(forKey defaultName: String) {
        savedData[defaultName] = nil
    }
    
    func clearSessionData() throws {
        savedData = [:]
    }
}

struct MockDefaultsStoreExpectation: DefaultsStoring, SessionBoundData {
    typealias ClearSessionDataAsFunction = () throws -> Void
    
    let mockDefaultsStore: MockDefaultsStore
    let clearSessionDataAsFunction: ClearSessionDataAsFunction

    init(mockDefaultsStore: MockDefaultsStore = MockDefaultsStore(), clearSessionDataAsFunction: @escaping ClearSessionDataAsFunction = { }) {
        self.mockDefaultsStore = mockDefaultsStore
        self.clearSessionDataAsFunction = clearSessionDataAsFunction
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        self.mockDefaultsStore.set(value, forKey: defaultName)
    }
    
    func value(forKey key: String) -> Any? {
        return self.mockDefaultsStore.value(forKey: key)
    }
    
    func bool(forKey: String) -> Bool {
        return self.mockDefaultsStore.bool(forKey: forKey)
    }
    
    func removeObject(forKey defaultName: String) {
        self.mockDefaultsStore.removeObject(forKey: defaultName)
    }
    
    func clearSessionData() throws {
        try self.mockDefaultsStore.clearSessionData()
        try self.clearSessionDataAsFunction()
    }

}
