import Foundation

protocol DefaultsStorable {
    func set(_ value: Any?, forKey defaultName: String)
    func value(forKey key: String) -> Any?
    func removeObject(forKey defaultName: String)
}

extension UserDefaults: DefaultsStorable { }

extension UserDefaults: SessionBoundData {
    func delete() throws {
        removeObject(forKey: .returningUser)
        removeObject(forKey: .accessTokenExpiry)
    }
}
