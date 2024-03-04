import Foundation

class MockDefaultsStore: DefaultsStorable {
    var returningAuthenticatedUser: Bool?
    var savedData: [ String: Any ] = [:]
    
    func set(_ value: Any?, forKey defaultName: String) {
        savedData[defaultName] = value
    }
    
    func value(forKey key: String) -> Any? {
        return returningAuthenticatedUser
    }
}
