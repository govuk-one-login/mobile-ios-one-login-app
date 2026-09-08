import Foundation
@testable import OneLogin

class MockDefaultsStore: DefaultsStoring, SessionBoundData {
    
    static func firstTimeUser() -> MockDefaultsStore {
        let unprotectedStore = MockDefaultsStore()
        unprotectedStore.set(false, forKey: OLString.returningUser)
        return unprotectedStore
    }

    static func returningUser() -> MockDefaultsStore {
        let unprotectedStore = MockDefaultsStore()
        unprotectedStore.set(true, forKey: OLString.returningUser)
        return unprotectedStore
    }
    
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
