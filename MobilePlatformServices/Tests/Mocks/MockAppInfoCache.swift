import Foundation
@testable import MobilePlatformServices

class MockAppInfoCache: DefaultsCache {
    var savedData = [String: Any]()
    
    func set(_ value: Any?, forKey defaultName: String) {
        savedData[defaultName] = value
    }
    
    func data(forKey key: String) -> Data? {
        savedData[key] as? Data
    }
}
