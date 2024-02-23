import Foundation

protocol DefaultsStorable {
    func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: DefaultsStorable { }
