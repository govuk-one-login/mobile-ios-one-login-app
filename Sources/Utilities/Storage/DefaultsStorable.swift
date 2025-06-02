import Foundation

protocol DefaultsStorable {
    func set(_ value: Any?, forKey defaultName: String)
    func value(forKey key: String) -> Any?
    func removeObject(forKey defaultName: String)
}

extension UserDefaults: DefaultsStorable { }

extension UserDefaults: SessionBoundData {
    func delete() throws {
        removeObject(forKey: OLString.returningUser)
        removeObject(forKey: OLString.accessTokenExpiry)
        removeObject(forKey: OLString.persistentSessionID)
    }
}
