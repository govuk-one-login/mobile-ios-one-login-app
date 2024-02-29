import Foundation

class MockDefaultsStore: DefaultsStorable {
    func value(forKey key: String) -> Any? {
        return nil
    }
    
    var savedData: [ String: Any ] = [:]
    
    func set(_ value: Any?, forKey defaultName: String) {
        savedData[defaultName] = value
    }
}
