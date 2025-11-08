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
    
    func string(forKey: String) -> String? {
        savedData[forKey] as? String
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
