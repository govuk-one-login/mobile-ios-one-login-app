import Foundation

protocol DefaultsCache {
    func set(_ value: Any?, forKey defaultName: String)
    func data(forKey key: String) -> Data?
}

extension UserDefaults: DefaultsCache { }
