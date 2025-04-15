import Foundation
@testable import MobilePlatformServices

protocol DefaultsStorable {
    func set(_ value: Any?, forKey defaultName: String)
    func data(forKey key: String) -> Data?
}

extension UserDefaults: DefaultsStorable { }

class MockAppInfoCache: DefaultsStorable {
    var savedData = [String: Any]()
    
    func set(_ value: Any?, forKey defaultName: String) {
        savedData[defaultName] = value
    }
    
    func data(forKey key: String) -> Data? {
        savedData[key] as? Data
    }
    
    func delete() throws {
        savedData = [:]
    }
}
