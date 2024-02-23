import Foundation

class MockDefaultsStore: DefaultsStorable {
    var dataSet: [ String: Any ] = [:]
    
    func set(_ value: Any?, forKey defaultName: String) {
        if let dateValue = value as? Date {
            dataSet[defaultName] = dateValue
        } else if let boolValue = value as? Bool {
            dataSet[defaultName] = boolValue
        }
    }
}
