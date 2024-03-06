import Foundation

class MockDefaultsStore: DefaultsStorable {
    var savedData: [ String: Any ] = [:]
    var returningAuthenticatedUser: Bool?
    
    func set(_ value: Any?, forKey defaultName: String) {
        savedData[defaultName] = value
    }
    
    func value(forKey key: String) -> Any? {
        return returningAuthenticatedUser
    }
}
