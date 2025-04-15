import Foundation
@testable import MobilePlatformServices

class MockAppInfoCache: UserDefaults {
    var savedData = [String: Any]()
    
    override func set(_ value: Any?, forKey defaultName: String) {
        savedData[defaultName] = value
    }
    
    override func data(forKey key: String) -> Data? {
        savedData[key] as? Data
    }
    
    func delete() throws {
        savedData = [:]
    }
}
