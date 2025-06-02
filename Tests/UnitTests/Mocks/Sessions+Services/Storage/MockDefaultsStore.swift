import Foundation
@testable import OneLogin

class MockDefaultsStore: DefaultsStorable, SessionBoundData {
    var savedData = [String: Any]()
    
    func set(_ value: Any?, forKey defaultName: String) {
        savedData[defaultName] = value
    }
    
    func value(forKey key: String) -> Any? {
        savedData[key]
    }
    
    func removeObject(forKey defaultName: String) {
        savedData[defaultName] = nil
    }
    
    func delete() throws {
        savedData = [:]
    }
}
