import Foundation

protocol DefaultsStoring {
    func set(_ value: Any?, forKey defaultName: String)
    func value(forKey key: String) -> Any?
    func bool(forKey: String) -> Bool
    func removeObject(forKey defaultName: String)
}

extension UserDefaults: DefaultsStoring { }
