import Foundation

class MockDefaultsStore: DefaultsStorable {
    var savedData: [ String: Any ] = [:]
    
    func set(_ value: Any?, forKey defaultName: String) {
        savedData[defaultName] = value
    }
}
